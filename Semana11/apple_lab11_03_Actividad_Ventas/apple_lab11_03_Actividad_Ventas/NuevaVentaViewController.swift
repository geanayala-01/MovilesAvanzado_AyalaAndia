//
//  NuevaVentaViewController.swift
//  A5 · Nueva venta (solo vendedor)
//

import UIKit
import CoreData

class NuevaVentaViewController: UITableViewController {

    var cliente: Cliente?
    var producto: Producto?
    var cantidad = 1
    let stepper = UIStepper()

    init() { super.init(style: .insetGrouped) }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        stepper.minimumValue = 1
        stepper.maximumValue = 999
        stepper.value = 1
        stepper.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.cantidad = Int(self.stepper.value)
            self.tableView.reloadData()
        }, for: .valueChanged)

        // ⑥ Registrar venta
        let boton = Formulario.botonPrincipal("Registrar venta")
        boton.addAction(UIAction { [weak self] _ in self?.registrar() }, for: .touchUpInside)
        let pie = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 70))
        boton.translatesAutoresizingMaskIntoConstraints = false
        pie.addSubview(boton)
        NSLayoutConstraint.activate([
            boton.leadingAnchor.constraint(equalTo: pie.leadingAnchor, constant: 20),
            boton.trailingAnchor.constraint(equalTo: pie.trailingAnchor, constant: -20),
            boton.centerYAnchor.constraint(equalTo: pie.centerYAnchor)
        ])
        tableView.tableFooterView = pie
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    var calculo: CalculoVenta? {
        guard let producto, let cliente else { return nil }
        return Reglas.calcular(precio: producto.precio, cantidad: cantidad, categoria: Reglas.categoria(cliente))
    }

    // MARK: - Secciones: 0 vendedor · 1 datos · 2 resumen

    override func numberOfSections(in tableView: UITableView) -> Int { 3 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        [1, 3, 4][section]
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        [nil, "Datos de la venta", "Resumen (calculado)"][section]
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let c = UITableViewCell(style: .value1, reuseIdentifier: nil)
        c.selectionStyle = .none
        switch (indexPath.section, indexPath.row) {
        case (0, _):
            // ① Vendedor de la sesión: automático, no editable
            var conf = UIListContentConfiguration.subtitleCell()
            conf.text = "\(Sesion.usuario?.nombre ?? "") · Vendedor"
            conf.secondaryText = "Sesión iniciada: la venta se registra a tu nombre"
            conf.image = UIImage(systemName: "person.crop.circle.fill")
            c.contentConfiguration = conf
            c.backgroundColor = .systemBlue.withAlphaComponent(0.12)
        case (1, 0):
            // ② Cliente
            c.textLabel?.text = "Cliente"
            if let cliente {
                c.detailTextLabel?.text = "\(cliente.nombre ?? "") · \(Reglas.categoria(cliente).rawValue)"
            } else { c.detailTextLabel?.text = "Elegir" }
            c.accessoryType = .disclosureIndicator
            c.selectionStyle = .default
        case (1, 1):
            // ③ Producto
            c.textLabel?.text = "Producto"
            c.detailTextLabel?.text = producto?.nombre ?? "Elegir"
            c.accessoryType = .disclosureIndicator
            c.selectionStyle = .default
        case (1, 2):
            // ④ Cantidad con stepper y stock disponible
            c.textLabel?.text = "Cantidad: \(cantidad)"
            c.detailTextLabel?.text = producto.map { "(stock \($0.stock))" }
            c.accessoryView = stepper
        default:
            // ⑤ Resumen calculado
            let k = calculo
            let filas: [(String, Double?)] = [
                ("Subtotal", k?.subtotal),
                ((cliente.map { Reglas.categoria($0) } == .vip) ? "Descuento VIP 10%" : "Descuento", k.map { -$0.descuento }),
                ("IGV 18%", k?.igv),
                ("Total", k?.total)
            ]
            let f = filas[indexPath.row]
            c.textLabel?.text = f.0
            c.detailTextLabel?.text = f.1.map { $0 < 0 ? "− " + (-$0).soles : $0.soles } ?? "—"
            if indexPath.row == 3 {
                c.textLabel?.font = .boldSystemFont(ofSize: 17)
                c.detailTextLabel?.font = .boldSystemFont(ofSize: 17)
                c.detailTextLabel?.textColor = .label
            }
        }
        return c
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.section == 1, indexPath.row < 2 else { return }
        let hoja = UIAlertController(title: indexPath.row == 0 ? "Cliente" : "Producto", message: nil, preferredStyle: .actionSheet)
        if indexPath.row == 0 {
            for cl in Datos.buscar(Cliente.self, orden: [NSSortDescriptor(key: "nombre", ascending: true)]) {
                hoja.addAction(UIAlertAction(title: "\(cl.nombre ?? "") (\(Reglas.categoria(cl).rawValue))", style: .default) { [weak self] _ in
                    self?.cliente = cl
                    self?.tableView.reloadData()
                })
            }
        } else {
            for p in Datos.buscar(Producto.self, orden: [NSSortDescriptor(key: "nombre", ascending: true)]) {
                hoja.addAction(UIAlertAction(title: "\(p.nombre ?? "") · \(p.precio.soles) · stock \(p.stock)", style: .default) { [weak self] _ in
                    self?.producto = p
                    self?.tableView.reloadData()
                })
            }
        }
        hoja.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        hoja.popoverPresentationController?.sourceView = tableView.cellForRow(at: indexPath)
        present(hoja, animated: true)
    }

    // MARK: - Registrar

    func registrar() {
        guard let cliente, let producto, let vendedor = Sesion.usuario, let k = calculo else {
            alerta("Faltan datos", "Elige un cliente y un producto.")
            return
        }
        // Regla de stock: si la cantidad supera el stock, no se registra
        guard Int64(cantidad) <= producto.stock else {
            alerta("Stock insuficiente", "Pediste \(cantidad) y solo hay \(producto.stock) de \(producto.nombre ?? ""). No se registró la venta.")
            return
        }
        let v = Venta(context: Datos.contexto)
        v.fecha = Date()
        v.cantidad = Int64(cantidad)
        v.precioUnitario = producto.precio
        v.descuento = k.descuento
        v.igv = k.igv
        v.total = k.total
        v.anulada = false
        v.vendedor = vendedor      // relación venta ▸ vendedor (quién la registró)
        v.cliente = cliente
        v.producto = producto
        producto.stock -= Int64(cantidad)   // baja el stock

        if let e = Datos.guardar() {
            alerta("Error", e.localizedDescription)
            return
        }
        alerta("Venta registrada", "Total \(k.total.soles). Stock de \(producto.nombre ?? ""): \(producto.stock).")
        self.cliente = nil
        self.producto = nil
        cantidad = 1
        stepper.value = 1
        tableView.reloadData()
    }
}
