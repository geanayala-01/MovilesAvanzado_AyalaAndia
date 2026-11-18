//
//  Modelos.swift
//  Grupo B · Caso Compras (SwiftUI + SwiftData)
//  Las 4 clases @Model con sus relaciones.
//

import Foundation
import SwiftData

@Model
final class Usuario {
    var nombre: String
    var usuario: String
    var clave: String
    var rol: String            // "Comprador" o "Supervisor"

    // No se puede borrar un usuario que tenga compras (.deny)
    @Relationship(deleteRule: .deny, inverse: \Compra.comprador)
    var compras: [Compra] = []

    init(nombre: String, usuario: String, clave: String, rol: String) {
        self.nombre = nombre
        self.usuario = usuario
        self.clave = clave
        self.rol = rol
    }
}

@Model
final class Proveedor {
    var nombre: String
    var ruc: String

    @Relationship(deleteRule: .deny, inverse: \Compra.proveedor)
    var compras: [Compra] = []

    init(nombre: String, ruc: String) {
        self.nombre = nombre
        self.ruc = ruc
    }
}

@Model
final class Producto {
    var nombre: String
    var categoria: String
    var stock: Int
    var costoPromedio: Double

    @Relationship(deleteRule: .deny, inverse: \Compra.producto)
    var compras: [Compra] = []

    init(nombre: String, categoria: String, stock: Int, costoPromedio: Double) {
        self.nombre = nombre
        self.categoria = categoria
        self.stock = stock
        self.costoPromedio = costoPromedio
    }
}

@Model
final class Compra {
    var fecha: Date
    var cantidad: Int
    var costoUnitario: Double
    var igv: Double
    var total: Double
    var alCredito: Bool
    var vence: Date
    var estado: String          // "Pendiente", "Aprobada" o "Rechazada"
    var pagada: Bool
    var motivoRechazo: String?

    var comprador: Usuario?
    var proveedor: Proveedor?
    var producto: Producto?

    init(fecha: Date, cantidad: Int, costoUnitario: Double, igv: Double, total: Double,
         alCredito: Bool, vence: Date, estado: String, pagada: Bool,
         comprador: Usuario?, proveedor: Proveedor?, producto: Producto?) {
        self.fecha = fecha
        self.cantidad = cantidad
        self.costoUnitario = costoUnitario
        self.igv = igv
        self.total = total
        self.alCredito = alCredito
        self.vence = vence
        self.estado = estado
        self.pagada = pagada
        self.comprador = comprador
        self.proveedor = proveedor
        self.producto = producto
    }

    var subtotal: Double { Reglas.redondear(Double(cantidad) * costoUnitario) }

    // Pendiente de pago con fecha vencida → VENCIDA
    var vencida: Bool { estado == Estado.aprobada && alCredito && !pagada && vence < Date() }
}

enum Rol {
    static let comprador = "Comprador"
    static let supervisor = "Supervisor"
}

enum Estado {
    static let pendiente = "Pendiente"
    static let aprobada = "Aprobada"
    static let rechazada = "Rechazada"
}
