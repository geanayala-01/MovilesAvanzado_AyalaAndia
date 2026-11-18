//
//  VentasViewControllers.swift
//  A6 · Mis ventas (vendedor) · A7 · Ventas del equipo (supervisor) · A8 · Anular venta
//

import UIKit
import CoreData

// MARK: - Base común: segmented Todas/Hoy/Mes + búsqueda por cliente + lista de ventas

class VentasBaseViewController: UITableViewController, UISearchResultsUpdating {

    var ventas = [Venta]()
    let segmento = UISegmentedControl(items: ["Todas", "Hoy", "Mes"])
    let buscador = UISearchController(searchResultsController: nil)

    init() { super.init(style: .insetGrouped) }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(FilaCell.self, forCellReuseIdentifier: FilaCell.id)
        segmento.selectedSegmentIndex = 0
        segmento.addAction(UIAction { [weak self] _ in self?.cargar() }, for: .valueChanged)
        buscador.searchResultsUpdater = self
        buscador.obscuresBackgroundDuringPresentation = false
        buscador.searchBar.placeholder = "Buscar por cliente"
        navigationItem.searchController = buscador
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cargar()
    }

    func updateSearchResults(for searchController: UISearchController) { cargar() }

    // Cada subclase agrega su filtro (vendedor de la sesión o chip de vendedor)
    func predicadoExtra() -> NSPredicate? { nil }
    func armarCabecera() {}

    // Fetch con NSPredicate: vendedor (relación) + periodo (fechas) + cliente (relación)
    func cargar() {
        var condiciones = [NSPredicate]()
        if let extra = predicadoExtra() { condiciones.append(extra) }
        if let p = Periodo(rawValue: segmento.selectedSegmentIndex)?.predicate { condiciones.append(p) }
        let texto = buscador.searchBar.text ?? ""
        if !texto.isEmpty { condiciones.append(NSPredicate(format: "cliente.nombre CONTAINS[cd] %@", texto)) }

        ventas = Datos.buscar(Venta.self,
                              predicate: NSCompoundPredicate(andPredicateWithSubpredicates: condiciones),
                              orden: [NSSortDescriptor(key: "fecha", ascending: false)])
        armarCabecera()
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { ventas.count }

    func mostrarVendedor() -> Bool { false }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let c = tableView.dequeueReusableCell(withIdentifier: FilaCell.id, for: indexPath) as! FilaCell
        let v = ventas[indexPath.row]
        let cliente = v.cliente?.nombre ?? "—"
        let detalle = "\(v.producto?.nombre ?? "") × \(v.cantidad)"
        // Nombre del vendedor leído desde la relación venta ▸ vendedor
        let quien = mostrarVendedor() ? (v.vendedor?.nombre ?? "—") + " · " : ""
        c.subtitulo.text = "\(v.fecha?.corta ?? "") · \(quien)\(detalle)"
        if v.anulada {
            // Venta anulada: tachada, con etiqueta, sin botón
            c.avatar.text = "✕"
            c.avatar.backgroundColor = .systemRed.withAlphaComponent(0.7)
            c.tachar(c.titulo, cliente)
            c.tachar(c.monto, v.total.soles)
            c.pill.mostrar("Anulada", .systemRed)
        } else {
            c.avatar.mostrar(cliente)
            c.titulo.text = cliente
            c.monto.text = v.total.soles
        }
        return c
    }
}

// MARK: - A6 · Mis ventas (vendedor: solo las suyas, sin anular)

class MisVentasViewController: VentasBaseViewController {

    let indHoy = IndicadorView("Hoy")
    let indMes = IndicadorView("Mes")

    override func predicadoExtra() -> NSPredicate? {
        // Visibilidad: el vendedor solo ve sus ventas
        guard let u = Sesion.usuario else { return NSPredicate(value: false) }
        return NSPredicate(format: "vendedor == %@", u)
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        "Solo aparecen las ventas de este vendedor."
    }

    // ① Indicadores propios (hoy y mes, solo ventas no anuladas) · ② Segmented
    override func armarCabecera() {
        guard let u = Sesion.usuario else { return }
        for (ind, periodo) in [(indHoy, Periodo.hoy), (indMes, Periodo.mes)] {
            let pred = NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "vendedor == %@ AND anulada == NO", u), periodo.predicate!
            ])
            let lista = Datos.buscar(Venta.self, predicate: pred)
            ind.valor.text = lista.reduce(0) { $0 + $1.total }.soles
            ind.detalle.text = "\(lista.count) ventas"
        }
        let fila = UIStackView(arrangedSubviews: [indHoy, indMes])
        fila.spacing = 12
        fila.distribution = .fillEqually
        tableView.tableHeaderView = cabecera([conMargen(fila, 20), conMargen(segmento, 20)], ancho: tableView.bounds.width)
    }

    // Ninguna fila permite Anular
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        UISwipeActionsConfiguration(actions: [])
    }
}

// MARK: - A7 · Ventas del equipo (supervisor: todas, filtro por vendedor, anular)

class VentasEquipoViewController: VentasBaseViewController {

    let chips = ChipsView()
    var vendedores = [Usuario]()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Ventas del equipo"   // la pestaña sigue diciendo "Ventas"
        chips.alCambiar = { [weak self] _ in self?.cargar() }
    }

    override func mostrarVendedor() -> Bool { true }

    // ① Chips por vendedor → predicate sobre la relación vendedor
    override func predicadoExtra() -> NSPredicate? {
        guard chips.seleccionado > 0, chips.seleccionado - 1 < vendedores.count else { return nil }
        return NSPredicate(format: "vendedor == %@", vendedores[chips.seleccionado - 1])
    }

    override func armarCabecera() {
        vendedores = Datos.buscar(Usuario.self, predicate: NSPredicate(format: "rol == %@", Rol.vendedor),
                                  orden: [NSSortDescriptor(key: "nombre", ascending: true)])
        chips.configurar(["Todos"] + vendedores.map { $0.nombre ?? "" })
        tableView.tableHeaderView = cabecera([conMargen(segmento, 20), chips], ancho: tableView.bounds.width)
    }

    // ④ Nota de la relación
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        "El nombre del vendedor se lee de la relación venta ▸ vendedor. Desliza una venta para anularla."
    }

    // ③ Deslizar para Anular (solo supervisor y solo ventas activas)
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let v = ventas[indexPath.row]
        guard Sesion.esSupervisor, !v.anulada else { return UISwipeActionsConfiguration(actions: []) }
        let anular = UIContextualAction(style: .destructive, title: "Anular") { [weak self] _, _, fin in
            self?.confirmarAnulacion(v)
            fin(true)
        }
        return UISwipeActionsConfiguration(actions: [anular])
    }

    // A8 · Alerta con resumen, motivo obligatorio y botón deshabilitado si está vacío
    func confirmarAnulacion(_ v: Venta) {
        let mensaje = "\(v.cliente?.nombre ?? "") · \(v.producto?.nombre ?? "") × \(v.cantidad) · \(v.total.soles)\n" +
                      "El stock se devolverá (+\(v.cantidad))."
        let a = UIAlertController(title: "Anular venta", message: mensaje, preferredStyle: .alert)
        let accion = UIAlertAction(title: "Anular", style: .destructive) { [weak self] _ in
            let motivo = (a.textFields?.first?.text ?? "").trimmingCharacters(in: .whitespaces)
            self?.anular(v, motivo: motivo)
        }
        accion.isEnabled = false
        a.addTextField { tf in
            tf.placeholder = "Motivo (obligatorio)"
            tf.addAction(UIAction { _ in
                accion.isEnabled = !(tf.text ?? "").trimmingCharacters(in: .whitespaces).isEmpty
            }, for: .editingChanged)
        }
        a.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        a.addAction(accion)
        present(a, animated: true)
    }

    // Marca anulada, guarda el motivo y devuelve el stock
    func anular(_ v: Venta, motivo: String) {
        guard !motivo.isEmpty, !v.anulada else { return }
        v.anulada = true
        v.motivoAnulacion = motivo
        v.producto?.stock += v.cantidad
        if let e = Datos.guardar() { alerta("Error", e.localizedDescription) }
        cargar()
    }
}
