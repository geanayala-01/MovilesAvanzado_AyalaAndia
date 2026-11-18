//
//  ClientesViewController.swift
//  A4 · Clientes (vendedor: crear, editar, consultar · supervisor: además borrar)
//

import UIKit
import CoreData

class ClientesViewController: UITableViewController, UISearchResultsUpdating {

    var clientes = [Cliente]()
    let buscador = UISearchController(searchResultsController: nil)

    init() { super.init(style: .insetGrouped) }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(FilaCell.self, forCellReuseIdentifier: FilaCell.id)
        // ① Botón + (ambos roles pueden crear)
        navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .add, primaryAction: UIAction { [weak self] _ in
            self?.formulario(nil)
        })
        buscador.searchResultsUpdater = self
        buscador.obscuresBackgroundDuringPresentation = false
        buscador.searchBar.placeholder = "Buscar por nombre o documento"
        navigationItem.searchController = buscador
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cargar()
    }

    func updateSearchResults(for searchController: UISearchController) { cargar() }

    func cargar() {
        let texto = buscador.searchBar.text ?? ""
        let predicate = texto.isEmpty ? nil
            : NSPredicate(format: "nombre CONTAINS[cd] %@ OR documento CONTAINS[cd] %@", texto, texto)
        clientes = Datos.buscar(Cliente.self, predicate: predicate, orden: [NSSortDescriptor(key: "nombre", ascending: true)])
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { clientes.count }

    // ③ Nota: categoría y "comprado" se calculan con las ventas no anuladas; no se guardan
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        "Categoría y total comprado se calculan con las ventas no anuladas; no se guardan."
    }

    // ② Fila: iniciales, nombre, documento y total comprado
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let c = tableView.dequeueReusableCell(withIdentifier: FilaCell.id, for: indexPath) as! FilaCell
        let cl = clientes[indexPath.row]
        let cat = Reglas.categoria(cl)
        c.avatar.mostrar(cl.nombre ?? "")
        c.titulo.text = cl.nombre
        c.subtitulo.text = cl.documento
        c.monto.text = Reglas.totalComprado(cl).soles
        c.pill.mostrar(cat.rawValue, cat.color)
        c.accessoryType = .disclosureIndicator
        return c
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        formulario(clientes[indexPath.row])
    }

    // Borrar: solo supervisor; Core Data lo impide si tiene ventas (Deny)
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard Sesion.esSupervisor else { return nil }
        let borrar = UIContextualAction(style: .destructive, title: "Borrar") { [weak self] _, _, fin in
            guard let self else { return }
            let cl = self.clientes[indexPath.row]
            Datos.contexto.delete(cl)
            if Datos.guardar() != nil {
                self.alerta("No se puede borrar", "\"\(cl.nombre ?? "")\" tiene ventas registradas.")
                fin(false)
            } else {
                fin(true)
            }
            self.cargar()
        }
        return UISwipeActionsConfiguration(actions: [borrar])
    }

    func formulario(_ cliente: Cliente?) {
        let a = UIAlertController(title: cliente == nil ? "Nuevo cliente" : "Editar cliente", message: nil, preferredStyle: .alert)
        a.addTextField { $0.placeholder = "Nombre o razón social"; $0.text = cliente?.nombre; $0.autocapitalizationType = .words }
        a.addTextField { $0.placeholder = "Documento (DNI / RUC)"; $0.text = cliente?.documento }
        a.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        a.addAction(UIAlertAction(title: "Guardar", style: .default) { [weak self] _ in
            let nombre = (a.textFields?[0].text ?? "").trimmingCharacters(in: .whitespaces)
            let doc = (a.textFields?[1].text ?? "").trimmingCharacters(in: .whitespaces)
            guard !nombre.isEmpty, !doc.isEmpty else {
                self?.alerta("Datos inválidos", "Completa nombre y documento.")
                return
            }
            let c = cliente ?? Cliente(context: Datos.contexto)
            c.nombre = nombre; c.documento = doc
            Datos.guardar()
            self?.cargar()
        })
        present(a, animated: true)
    }
}
