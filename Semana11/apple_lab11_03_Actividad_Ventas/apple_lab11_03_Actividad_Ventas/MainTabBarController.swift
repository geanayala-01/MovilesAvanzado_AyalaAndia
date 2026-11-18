//
//  MainTabBarController.swift
//  Pestañas según el rol del usuario de la sesión.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        func nav(_ vc: UIViewController, _ titulo: String, _ icono: String) -> UINavigationController {
            vc.title = titulo
            let n = UINavigationController(rootViewController: vc)
            n.tabBarItem = UITabBarItem(title: titulo, image: UIImage(systemName: icono), selectedImage: nil)
            return n
        }

        if Sesion.esSupervisor {
            // Supervisor: Resumen, Ventas, Productos, Clientes, Cuenta
            viewControllers = [
                nav(ResumenViewController(), "Resumen", "chart.bar.fill"),
                nav(VentasEquipoViewController(), "Ventas", "list.bullet.rectangle"),
                nav(ProductosViewController(), "Productos", "shippingbox.fill"),
                nav(ClientesViewController(), "Clientes", "person.2.fill"),
                nav(CuentaViewController(), "Cuenta", "person.crop.circle")
            ]
        } else {
            // Vendedor: Productos, Clientes, Venta, Mis ventas, Cuenta
            viewControllers = [
                nav(ProductosViewController(), "Productos", "shippingbox.fill"),
                nav(ClientesViewController(), "Clientes", "person.2.fill"),
                nav(NuevaVentaViewController(), "Venta", "cart.badge.plus"),
                nav(MisVentasViewController(), "Mis ventas", "list.bullet.rectangle"),
                nav(CuentaViewController(), "Cuenta", "person.crop.circle")
            ]
        }
    }
}
