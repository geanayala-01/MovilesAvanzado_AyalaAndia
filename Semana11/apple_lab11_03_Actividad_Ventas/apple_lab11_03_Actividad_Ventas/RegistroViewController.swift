//
//  RegistroViewController.swift
//  A2 · Crear cuenta
//

import UIKit
import CoreData

class RegistroViewController: UIViewController {

    let txtNombre = UITextField()
    let txtUsuario = UITextField()
    let lblDisponible = UILabel()
    let txtClave = UITextField()
    let txtConfirmar = UITextField()
    let segRol = UISegmentedControl(items: [Rol.vendedor, Rol.supervisor])
    let lblError = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        // ① Título (el botón "< Ingresar" lo pone el UINavigationController)
        title = "Crear cuenta"
        view.backgroundColor = .systemGroupedBackground

        // ② Nombre completo · ③ Usuario único · ④ Clave y confirmación
        Formulario.campo(txtNombre, "Nombre completo")
        txtNombre.autocapitalizationType = .words
        Formulario.campo(txtUsuario, "Usuario")
        Formulario.campo(txtClave, "Clave (mínimo 6 caracteres)", seguro: true)
        Formulario.campo(txtConfirmar, "Confirmar clave", seguro: true)

        // Aviso en vivo si el usuario ya existe
        lblDisponible.font = .systemFont(ofSize: 13)
        txtUsuario.addAction(UIAction { [weak self] _ in self?.revisarUsuario() }, for: .editingChanged)

        // ⑤ Rol
        let lblRol = UILabel()
        lblRol.text = "TU ROL"
        lblRol.font = .systemFont(ofSize: 12)
        lblRol.textColor = .secondaryLabel
        segRol.selectedSegmentIndex = 0

        lblError.textColor = .systemRed
        lblError.font = .systemFont(ofSize: 14)
        lblError.numberOfLines = 0
        lblError.isHidden = true

        // ⑥ Registrarme
        let btn = Formulario.botonPrincipal("Registrarme")
        btn.addAction(UIAction { [weak self] _ in self?.registrar() }, for: .touchUpInside)

        let nota = UILabel()
        nota.text = "Al registrarte entrarás directamente a la app con las pestañas de tu rol."
        nota.font = .systemFont(ofSize: 12)
        nota.textColor = .secondaryLabel
        nota.numberOfLines = 0
        nota.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [txtNombre, txtUsuario, lblDisponible, txtClave, txtConfirmar,
                                                   lblRol, segRol, lblError, btn, nota])
        stack.axis = .vertical
        stack.spacing = 12
        Formulario.montar(stack, en: view)
    }

    // Usuario único sin distinguir mayúsculas: "lparedes" == "LPAREDES"
    func usuarioExiste(_ u: String) -> Bool {
        !Datos.buscar(Usuario.self, predicate: NSPredicate(format: "usuario ==[c] %@", u)).isEmpty
    }

    func revisarUsuario() {
        let u = (txtUsuario.text ?? "").trimmingCharacters(in: .whitespaces)
        if u.isEmpty { lblDisponible.text = nil; return }
        if usuarioExiste(u) {
            lblDisponible.text = "✗ Ese usuario ya existe"
            lblDisponible.textColor = .systemRed
        } else {
            lblDisponible.text = "✓ Disponible"
            lblDisponible.textColor = .systemGreen
        }
    }

    func registrar() {
        let nombre = (txtNombre.text ?? "").trimmingCharacters(in: .whitespaces)
        let usuario = (txtUsuario.text ?? "").trimmingCharacters(in: .whitespaces)
        let clave = txtClave.text ?? ""
        let confirmar = txtConfirmar.text ?? ""

        var error: String?
        if nombre.isEmpty || usuario.isEmpty { error = "Completa nombre y usuario." }
        else if usuarioExiste(usuario) { error = "El usuario \"\(usuario)\" ya existe." }
        else if clave.count < 6 { error = "La clave debe tener mínimo 6 caracteres." }
        else if clave != confirmar { error = "Las claves no coinciden." }

        if let error {
            lblError.text = error
            lblError.isHidden = false
            return
        }

        let u = Usuario(context: Datos.contexto)
        u.nombre = nombre
        u.usuario = usuario
        u.clave = clave
        u.rol = segRol.selectedSegmentIndex == 0 ? Rol.vendedor : Rol.supervisor
        if let e = Datos.guardar() {
            alerta("Error", e.localizedDescription)
            return
        }
        // Entra directo a la app
        Sesion.iniciar(u)
        SceneDelegate.mostrarApp()
    }
}
