//
//  Datos.swift
//  Conexión a Core Data, sesión del usuario y reglas de negocio.
//

import UIKit
import CoreData

// MARK: - Conexión con Core Data

enum Datos {

    // Contexto principal (igual que conexion() del laboratorio)
    static var contexto: NSManagedObjectContext {
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }

    // Guarda cambios. Si falla (por ejemplo, delete rule Deny), deshace y devuelve el error.
    @discardableResult
    static func guardar() -> Error? {
        guard contexto.hasChanges else { return nil }
        do {
            try contexto.save()
            return nil
        } catch {
            contexto.rollback()
            print("Error al guardar: \(error)")
            return error
        }
    }

    // Fetch genérico con predicate y orden
    static func buscar<T: NSManagedObject>(_ tipo: T.Type,
                                            predicate: NSPredicate? = nil,
                                            orden: [NSSortDescriptor] = []) -> [T] {
        let request = NSFetchRequest<T>(entityName: String(describing: tipo))
        request.predicate = predicate
        request.sortDescriptors = orden
        return (try? contexto.fetch(request)) ?? []
    }
}

// MARK: - Sesión (la app recuerda al usuario mientras está abierta)

enum Sesion {
    static var usuario: Usuario?

    static var esSupervisor: Bool { usuario?.rol == Rol.supervisor }

    static func iniciar(_ u: Usuario) { usuario = u }
    static func cerrar() { usuario = nil }
}

enum Rol {
    static let vendedor = "Vendedor"
    static let supervisor = "Supervisor"
}

// MARK: - Reglas de negocio

enum CategoriaCliente: String {
    case regular = "Regular"
    case frecuente = "Frecuente"
    case vip = "VIP"

    var color: UIColor {
        switch self {
        case .regular: return .systemGray
        case .frecuente: return .systemBlue
        case .vip: return .systemPurple
        }
    }
}

struct CalculoVenta {
    let subtotal: Double
    let descuento: Double
    let igv: Double
    let total: Double
}

enum Reglas {
    static let tasaIGV = 0.18
    static let descuentoVIP = 0.10

    // Total comprado = suma de ventas NO anuladas del cliente (se calcula, no se guarda)
    static func totalComprado(_ cliente: Cliente) -> Double {
        let ventas = (cliente.ventas as? Set<Venta>) ?? []
        return ventas.filter { !$0.anulada }.reduce(0) { $0 + $1.total }
    }

    // Regular < 1000 · Frecuente desde 1000 · VIP desde 5000
    static func categoria(_ cliente: Cliente) -> CategoriaCliente {
        let total = totalComprado(cliente)
        if total >= 5000 { return .vip }
        if total >= 1000 { return .frecuente }
        return .regular
    }

    // Descuento VIP 10% del subtotal · IGV 18% sobre (subtotal - descuento)
    static func calcular(precio: Double, cantidad: Int, categoria: CategoriaCliente) -> CalculoVenta {
        let subtotal = redondear(precio * Double(cantidad))
        let descuento = categoria == .vip ? redondear(subtotal * descuentoVIP) : 0
        let igv = redondear((subtotal - descuento) * tasaIGV)
        let total = redondear(subtotal - descuento + igv)
        return CalculoVenta(subtotal: subtotal, descuento: descuento, igv: igv, total: total)
    }

    static func redondear(_ v: Double) -> Double { (v * 100).rounded() / 100 }
}

// MARK: - Fechas para los filtros (NSPredicate por periodo)

enum Periodo: Int {
    case todas = 0, hoy, mes

    // Rango [desde, hasta) del periodo; nil = sin filtro de fecha
    var rango: (Date, Date)? {
        let cal = Calendar.current
        let ahora = Date()
        switch self {
        case .todas: return nil
        case .hoy:
            let inicio = cal.startOfDay(for: ahora)
            return (inicio, cal.date(byAdding: .day, value: 1, to: inicio)!)
        case .mes:
            let inicio = cal.date(from: cal.dateComponents([.year, .month], from: ahora))!
            return (inicio, cal.date(byAdding: .month, value: 1, to: inicio)!)
        }
    }

    var predicate: NSPredicate? {
        guard let (desde, hasta) = rango else { return nil }
        return NSPredicate(format: "fecha >= %@ AND fecha < %@", desde as NSDate, hasta as NSDate)
    }
}

// MARK: - Formato

extension Double {
    var soles: String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        f.locale = Locale(identifier: "en_US")
        return "S/ " + (f.string(from: NSNumber(value: self)) ?? "0.00")
    }
}

extension Date {
    var corta: String {
        let f = DateFormatter()
        f.dateFormat = "dd/MM HH:mm"
        return f.string(from: self)
    }
}

func iniciales(_ nombre: String) -> String {
    let partes = nombre.split(separator: " ").prefix(2)
    return partes.compactMap { $0.first.map(String.init) }.joined().uppercased()
}
