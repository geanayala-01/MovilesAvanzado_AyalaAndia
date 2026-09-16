// ===== ACTIVIDAD PROPUESTA 02 — CLIENTE BANCARIO (HERENCIA Y POLIMORFISMO) =====
// Alumno: Ayala Andia
// Enunciado: modelar Cliente (base) y sus dos tipos: ClienteNatural y ClienteJuridico.
// Cada subclase sobrescribe mostrarDatos() para mostrar primero sus datos propios
// y luego, con super.mostrarDatos(), los datos comunes de Cliente.

import Foundation

class Cliente {
    let codigo: String
    let direccion: String
    let fechaDeRegistro: String
    let numeroCuenta: String
    let montoMinimoApertura: Double

    init(codigo: String, direccion: String, fechaDeRegistro: String, numeroCuenta: String, montoMinimoApertura: Double) {
        self.codigo = codigo
        self.direccion = direccion
        self.fechaDeRegistro = fechaDeRegistro
        self.numeroCuenta = numeroCuenta
        self.montoMinimoApertura = montoMinimoApertura
    }

    func mostrarDatos() {
        print("📄 Código: \(codigo)")
        print("📍 Dirección: \(direccion)")
        print("📝 Fecha de registro: \(fechaDeRegistro)")
        print("🏦 N° Cuenta: \(numeroCuenta)")
        print("💰 Monto mínimo de apertura: S/ \(String(format: "%.2f", montoMinimoApertura))")
    }
}
