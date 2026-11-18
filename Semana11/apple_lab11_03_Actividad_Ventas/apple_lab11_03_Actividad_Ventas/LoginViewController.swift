//
//  LoginViewController.swift
//  A1 · Inicio de sesión
//

import UIKit
import CoreData

class LoginViewController: UIViewController {

    let txtUsuario = UITextField()
    let txtClave = UITextField()
    let lblError = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground

        // ① Logo y nombre
        let logo = UIImageView(image: UIImage(systemName: "cart.fill"))
        logo.tintColor = .white
        logo.contentMode = .center
        logo.backgroundColor = .systemBlue
        logo.layer.cornerRadius = 22
        logo.preferredSymbolConfiguration = .init(pointSize: 40)
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.widthAnchor.constraint(equalToConstant: 90).isActive = true
        logo.heightAnchor.constraint(equalToConstant: 90).isActive = true

        let titulo = UILabel()
        titulo.text = "Ventas Tecsup"
        titulo.font = .systemFont(ofSize: 28, weight: .bold)
        let sub = UILabel()
        sub.text = "Inicia sesión para continuar"
        sub.textColor = .secondaryLabel

        // ② Usuario · ③ Clave oculta
        Formulario.campo(txtUsuario, "Usuario")
        Formulario.campo(txtClave, "Clave", seguro: true)

        // ④ Mensaje de error genérico
        lblError.textColor = .systemRed
        lblError.font = .systemFont(ofSize: 14)
        lblError.isHidden = true

        // ⑤ Ingresar
        let btnIngresar = Formulario.botonPrincipal("Ingresar")
        btnIngresar.addAction(UIAction { [weak self] _ in self?.ingresar() }, for: .touchUpInside)

        // ⑥ Ir a Crear cuenta
        let btnCrear = UIButton(type: .system)
        btnCrear.setTitle("¿Primera vez? Crear cuenta", for: .normal)
        btnCrear.addAction(UIAction { [weak self] _ in
            self?.navigationController?.pushViewController(RegistroViewController(), animated: true)
        }, for: .touchUpInside)

        let demo = UILabel()
        demo.text = "Demo: cruiz / adiaz (Vendedor) · supervisor (Supervisor) · clave 123456"
        demo.font = .systemFont(ofSize: 12)
        demo.textColor = .tertiaryLabel
        demo.numberOfLines = 0
        demo.textAlignment = .center

        let cabeza = UIStackView(arrangedSubviews: [logo, titulo, sub])
        cabeza.axis = .vertical
        cabeza.alignment = .center
        cabeza.spacing = 8

        let stack = UIStackView(arrangedSubviews: [cabeza, txtUsuario, txtClave, lblError, btnIngresar, btnCrear, demo])
        stack.axis = .vertical
        stack.spacing = 14
        stack.setCustomSpacing(30, after: cabeza)
        Formulario.montar(stack, en: view)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    func ingresar() {
        let usuario = (txtUsuario.text ?? "").trimmingCharacters(in: .whitespaces)
        let clave = txtClave.text ?? ""

        // Busca usuario (sin distinguir mayúsculas) y clave exacta
        let predicate = NSPredicate(format: "usuario ==[c] %@ AND clave == %@", usuario, clave)
        if let u = Datos.buscar(Usuario.self, predicate: predicate).first {
            lblError.isHidden = true
            Sesion.iniciar(u)
            SceneDelegate.mostrarApp()
        } else {
            // Mensaje genérico: no dice si falló el usuario o la clave
            lblError.text = "⚠︎ Usuario o clave incorrectos"
            lblError.isHidden = false
        }
    }
}

// MARK: - Helpers de formulario (Login y Registro)

enum Formulario {
    static func campo(_ t: UITextField, _ placeholder: String, seguro: Bool = false) {
        t.placeholder = placeholder
        t.isSecureTextEntry = seguro
        t.autocapitalizationType = .none
        t.autocorrectionType = .no
        t.borderStyle = .none
        t.backgroundColor = .secondarySystemGroupedBackground
        t.layer.cornerRadius = 12
        t.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 1))
        t.leftViewMode = .always
        t.heightAnchor.constraint(equalToConstant: 50).isActive = true
        if seguro { t.textContentType = .oneTimeCode } // evita el autollenado de contraseñas del sistema
    }

    static func botonPrincipal(_ titulo: String) -> UIButton {
        var c = UIButton.Configuration.filled()
        c.title = titulo
        c.cornerStyle = .large
        c.buttonSize = .large
        return UIButton(configuration: c)
    }

    static func montar(_ stack: UIStackView, en view: UIView) {
        let scroll = UIScrollView()
        scroll.keyboardDismissMode = .interactive
        scroll.translatesAutoresizingMaskIntoConstraints = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        scroll.addSubview(stack)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 40),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -20),
            stack.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -24)
        ])
    }
}
