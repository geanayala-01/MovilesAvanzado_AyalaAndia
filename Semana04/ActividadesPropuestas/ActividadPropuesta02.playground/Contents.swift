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

class ClienteNatural: Cliente {
    let nombreCompleto: String
    let dni: String

    init(codigo: String, direccion: String, fechaDeRegistro: String, numeroCuenta: String, montoMinimoApertura: Double, nombreCompleto: String, dni: String) {
        self.nombreCompleto = nombreCompleto
        self.dni = dni
        super.init(codigo: codigo, direccion: direccion, fechaDeRegistro: fechaDeRegistro, numeroCuenta: numeroCuenta, montoMinimoApertura: montoMinimoApertura)
    }

    override func mostrarDatos() {
        print("👤 Cliente Natural:")
        print("Nombre: \(nombreCompleto)")
        print("DNI: \(dni)")
        super.mostrarDatos()
    }
}

class ClienteJuridico: Cliente {
    let razonSocial: String
    let ruc: String
    let representanteLegal: String

    init(codigo: String, direccion: String, fechaDeRegistro: String, numeroCuenta: String, montoMinimoApertura: Double, razonSocial: String, ruc: String, representanteLegal: String) {
        self.razonSocial = razonSocial
        self.ruc = ruc
        self.representanteLegal = representanteLegal
        super.init(codigo: codigo, direccion: direccion, fechaDeRegistro: fechaDeRegistro, numeroCuenta: numeroCuenta, montoMinimoApertura: montoMinimoApertura)
    }

    override func mostrarDatos() {
        print("🏢 Cliente Jurídico:")
        print("Razón Social: \(razonSocial)")
        print("RUC: \(ruc)")
        print("Representante Legal: \(representanteLegal)")
        super.mostrarDatos()
    }
}

// --- Menú interactivo por terminal (ejecutar con: swift Contents.swift) ---
var clientes: [Cliente] = []
var salir = false

while !salir {
    print("\n===== MENÚ CLIENTES =====")
    print("1. Registrar Cliente Natural")
    print("2. Registrar Cliente Jurídico")
    print("3. Listar clientes registrados")
    print("4. Salir")
    print("Elige una opción: ")
    let opcion = readLine() ?? ""

    switch opcion {
    case "1":
        print("Código: ")
        let codigo = readLine() ?? ""
        print("Dirección: ")
        let direccion = readLine() ?? ""
        print("Fecha de registro (aaaa-mm-dd): ")
        let fecha = readLine() ?? ""
        print("N° de cuenta: ")
        let cuenta = readLine() ?? ""
        print("Monto mínimo de apertura: ")
        let monto = Double(readLine() ?? "0") ?? 0.0
        print("Nombre completo: ")
        let nombre = readLine() ?? ""
        print("DNI: ")
        let dni = readLine() ?? ""
        let nuevoCliente = ClienteNatural(codigo: codigo, direccion: direccion, fechaDeRegistro: fecha, numeroCuenta: cuenta, montoMinimoApertura: monto, nombreCompleto: nombre, dni: dni)
        clientes.append(nuevoCliente)
        print("✅ Cliente natural registrado.")

    case "2":
        print("Código: ")
        let codigo = readLine() ?? ""
        print("Dirección: ")
        let direccion = readLine() ?? ""
        print("Fecha de registro (aaaa-mm-dd): ")
        let fecha = readLine() ?? ""
        print("N° de cuenta: ")
        let cuenta = readLine() ?? ""
        print("Monto mínimo de apertura: ")
        let monto = Double(readLine() ?? "0") ?? 0.0
        print("Razón Social: ")
        let razonSocial = readLine() ?? ""
        print("RUC: ")
        let ruc = readLine() ?? ""
        print("Representante Legal: ")
        let representante = readLine() ?? ""
        let nuevoCliente = ClienteJuridico(codigo: codigo, direccion: direccion, fechaDeRegistro: fecha, numeroCuenta: cuenta, montoMinimoApertura: monto, razonSocial: razonSocial, ruc: ruc, representanteLegal: representante)
        clientes.append(nuevoCliente)
        print("✅ Cliente jurídico registrado.")

    case "3":
        // Recorrido polimórfico: un solo for-in sobre [Cliente]
        print("\n===== CLIENTES REGISTRADOS =====")
        if clientes.count == 0 {
            print("Todavía no hay clientes registrados.")
        } else {
            for cliente in clientes {
                cliente.mostrarDatos()
                print("--------------------")
            }
        }

    case "4":
        print("Saliendo del programa...")
        salir = true

    default:
        print("Opción inválida, intenta de nuevo.")
    }
}
