//
//  AppDelegate.swift
//  apple_lab11_03_Actividad_Ventas
//
//  Grupo A · Caso Ventas (UIKit + Core Data)
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let ruta = persistentContainer.persistentStoreDescriptions.first?.url?.path ?? "sin ruta"
        print("Base de datos SQLite en: \(ruta)")
        DatosIniciales.cargarSiEstaVacio(en: persistentContainer.viewContext)
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    // MARK: - Core Data stack

    // El contenedor carga el modelo "VentasModel.xcdatamodeld" (Usuario, Producto, Cliente, Venta)
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "VentasModel")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Error al cargar Core Data \(error), \(error.userInfo)")
            }
        }
        return container
    }()
}
