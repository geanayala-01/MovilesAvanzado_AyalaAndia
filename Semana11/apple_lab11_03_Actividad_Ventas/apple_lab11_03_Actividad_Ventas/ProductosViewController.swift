//
//  ProductosViewController.swift
//  A3 · Productos (vendedor: consultar y buscar · supervisor: crear, editar y borrar)
//

import UIKit
import CoreData

class ProductosViewController: UITableViewController, UISearchResultsUpdating {

    var productos = [Producto]()
    var categorias = [String]()
    let chips = ChipsView()
    let buscador = UISearchController(searchResultsController: nil)

    init() { super.init(style: .insetGrouped) }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(FilaCell.self, forCellReuseIdentifier: FilaCell.id)

        // ① Botón + solo para el supervisor
        if Sesion.esSupervisor {
            navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .add, primaryAction: UIAction { [weak self] _ in
                self?.formulario(nil)
            })
        }

        // ② Búsqueda
        buscador.searchResultsUpdater = self
        buscador.obscuresBackgroundDuringPresentation = false
        buscador.searchBar.placeholder = "Buscar producto"
        navigationItem.searchController = buscador
        navigationItem.hidesSearchBarWhenScrolling = false

        // ③ Chips de categoría
        chips.alCambiar = { [weak self] _ in self?.cargar() }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cargar()
    }

    func updateSearchResults(for searchController: UISearchController) { cargar() }

    // Fetch con NSPredicate compuesto: categoría + texto de búsqueda
    func cargar() {
        let todas = Set(Datos.buscar(Producto.self).compactMap { $0.categoria })
        categorias = todas.sorted()
        chips.configurar(["Todos"] + categorias)
        chips.frame.size = CGSize(width: tableView.bounds.width, height: 44)
        tableView.tableHeaderView = chips

        var condiciones = [NSPredicate]()
        if chips.seleccionado > 0 {
            condiciones.append(NSPredicate(format: "categoria == %@", categorias[chips.seleccionado - 1]))
        }
        let texto = buscador.searchBar.text ?? ""
        if !texto.isEmpty {
            condiciones.append(NSPredicate(format: "nombre CONTAINS[cd] %@", texto))
        }
        productos = Datos.buscar(Producto.self,
                                 predicate: NSCompoundPredicate(andPredicateWithSubpredicates: condiciones),
                                 orden: [NSSortDescriptor(key: "nombre", ascending: true)])
        tableView.reloadData()
    }

    // MARK: - Tabla

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { productos.count }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        Sesion.esSupervisor ? "Desliza para borrar. No se puede borrar un producto con ventas."
                            : "Vista del vendedor: solo consulta."
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let c = tableView.dequeueReusableCell(withIdentifier: FilaCell.id, for: indexPath) as! FilaCell
        let p = productos[indexPath.row]
        c.avatar.mostrar(p.nombre ?? "")
        c.titulo.text = p.nombre
        c.subtitulo.text = p.categoria
        c.monto.text = p.precio.soles
        // ④ Stock en color: verde > 10 · ámbar 6–10 · rojo ≤ 5
        let color: UIColor = p.stock > 10 ? .systemGreen : (p.stock >= 6 ? .systemOrange : .systemRed)
        c.pill.mostrar("\(p.stock) u.", color)
        c.accessoryType = Sesion.esSupervisor ? .disclosureIndicator : .none
        return c
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if Sesion.esSupervisor { formulario(productos[indexPath.row]) }
    }

    // ⑤ Deslizar para borrar (solo supervisor; bloqueado si tiene ventas → delete rule Deny)
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard Sesion.esSupervisor else { return nil }
        let borrar = UIContextualAction(style: .destructive, title: "Borrar") { [weak self] _, _, fin in
            guard let self else { return }
            let p = self.productos[indexPath.row]
            Datos.contexto.delete(p)
            if Datos.guardar() != nil {
                // Core Data rechazó el borrado por la regla Deny
                self.alerta("No se puede borrar", "\"\(p.nombre ?? "")\" tiene ventas registradas.")
                fin(false)
            } else {
                fin(true)
            }
            self.cargar()
        }
        return UISwipeActionsConfiguration(actions: [borrar])
    }

    // MARK: - Crear / editar (supervisor)

    func formulario(_ producto: Producto?) {
        let a = UIAlertController(title: producto == nil ? "Nuevo producto" : "Editar producto", message: nil, preferredStyle: .alert)
        a.addTextField { $0.placeholder = "Nombre"; $0.text = producto?.nombre }
        a.addTextField { $0.placeholder = "Categoría"; $0.text = producto?.categoria }
        a.addTextField {
            $0.placeholder = "Precio"; $0.keyboardType = .decimalPad
            if let p = producto { $0.text = String(format: "%.2f", p.precio) }
        }
        a.addTextField {
            $0.placeholder = "Stock"; $0.keyboardType = .numberPad
            if let p = producto { $0.text = "\(p.stock)" }
        }
        a.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        a.addAction(UIAlertAction(title: "Guardar", style: .default) { [weak self] _ in
            let f = a.textFields ?? []
            let nombre = (f[0].text ?? "").trimmingCharacters(in: .whitespaces)
            let categoria = (f[1].text ?? "").trimmingCharacters(in: .whitespaces)
            guard !nombre.isEmpty, !categoria.isEmpty,
                  let precio = Double((f[2].text ?? "").replacingOccurrences(of: ",", with: ".")), precio > 0,
                  let stock = Int64(f[3].text ?? ""), stock >= 0 else {
                self?.alerta("Datos inválidos", "Completa nombre, categoría, precio (> 0) y stock (≥ 0).")
                return
            }
            let p = producto ?? Producto(context: Datos.contexto)
            p.nombre = nombre; p.categoria = categoria; p.precio = precio; p.stock = stock
            Datos.guardar()
            self?.cargar()
        })
        present(a, animated: true)
    }
}
