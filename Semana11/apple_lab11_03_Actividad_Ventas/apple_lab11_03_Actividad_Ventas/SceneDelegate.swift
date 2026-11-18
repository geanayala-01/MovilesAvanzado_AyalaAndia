//
//  SceneDelegate.swift
//  apple_lab11_03_Actividad_Ventas
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    // La app arranca en el Login (no usamos Main.storyboard: todo se arma por código)
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UINavigationController(rootViewController: LoginViewController())
        window.makeKeyAndVisible()
        self.window = window
    }

    // Cambia la pantalla raíz: Login <-> TabBar según haya sesión o no
    static func mostrarApp() {
        cambiarRaiz(MainTabBarController())
    }

    static func mostrarLogin() {
        Sesion.cerrar()
        cambiarRaiz(UINavigationController(rootViewController: LoginViewController()))
    }

    private static func cambiarRaiz(_ vc: UIViewController) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let delegate = scene.delegate as? SceneDelegate,
              let window = delegate.window else { return }
        window.rootViewController = vc
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
    }
}
