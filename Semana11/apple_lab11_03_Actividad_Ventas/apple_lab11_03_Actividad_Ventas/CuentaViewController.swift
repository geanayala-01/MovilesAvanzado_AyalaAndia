//
//  CuentaViewController.swift
//  Pestaña Cuenta: nombre, usuario, rol y Cerrar sesión.
//

import UIKit

class CuentaViewController: UITableViewController {

    init() { super.init(style: .insetGrouped) }
    required init?(coder: NSCoder) { fatalError() }

    var filas: [(String, String)] {
        let u = Sesion.usuario
        return [("Nombre", u?.nombre ?? ""), ("Usuario", u?.usuario ?? ""), ("Rol", u?.rol ?? "")]
    }

    override func numberOfSections(in tableView: UITableView) -> Int { 2 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? filas.count : 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let c = UITableViewCell(style: .value1, reuseIdentifier: nil)
        if indexPath.section == 0 {
            c.textLabel?.text = filas[indexPath.row].0
            c.detailTextLabel?.text = filas[indexPath.row].1
            c.selectionStyle = .none
        } else {
            var conf = UIListContentConfiguration.cell()
            conf.text = "Cerrar sesión"
            conf.textProperties.color = .systemRed
            conf.textProperties.alignment = .center
            c.contentConfiguration = conf
        }
        return c
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 { SceneDelegate.mostrarLogin() }
    }
}
