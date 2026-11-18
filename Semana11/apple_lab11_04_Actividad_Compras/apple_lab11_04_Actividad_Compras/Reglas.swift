//
//  Reglas.swift
//  Reglas de negocio, sesión y datos de prueba.
//

import SwiftUI
import SwiftData

// MARK: - Reglas de negocio

enum Reglas {
    static let tasaIGV = 0.18
    static let limiteAprobacion = 5000.0
    static let diasCredito = 30

    static func redondear(_ v: Double) -> Double { (v * 100).rounded() / 100 }

    // IGV 18 % sobre el subtotal (es crédito fiscal). Total = subtotal + IGV
    static func calcular(cantidad: Int, costo: Double) -> (subtotal: Double, igv: Double, total: Double) {
        let subtotal = redondear(Double(cantidad) * costo)
        let igv = redondear(subtotal * tasaIGV)
        return (subtotal, igv, redondear(subtotal + igv))
    }

    // Costo promedio ponderado = (stock × costoProm + cantidad × costo) / (stock + cantidad)
    static func nuevoCostoPromedio(stock: Int, costoProm: Double, cantidad: Int, costo: Double) -> Double {
        let unidades = stock + cantidad
        guard unidades > 0 else { return costo }
        return redondear((Double(stock) * costoProm + Double(cantidad) * costo) / Double(unidades))
    }

    // Aplica los efectos de una compra aprobada: sube stock y recalcula el costo promedio
    static func aplicarEfectos(_ c: Compra) {
        guard let p = c.producto else { return }
        p.costoPromedio = nuevoCostoPromedio(stock: p.stock, costoProm: p.costoPromedio,
                                             cantidad: c.cantidad, costo: c.costoUnitario)
        p.stock += c.cantidad
    }

    // Registra una compra: < S/ 5,000 se aprueba al instante; desde S/ 5,000 queda Pendiente
    @discardableResult
    static func registrar(en ctx: ModelContext, comprador: Usuario, proveedor: Proveedor, producto: Producto,
                          cantidad: Int, costo: Double, alCredito: Bool, fecha: Date = Date()) -> Compra {
        let k = calcular(cantidad: cantidad, costo: costo)
        let estado = k.total < limiteAprobacion ? Estado.aprobada : Estado.pendiente
        let vence = Calendar.current.date(byAdding: .day, value: diasCredito, to: fecha)!
        let c = Compra(fecha: fecha, cantidad: cantidad, costoUnitario: costo, igv: k.igv, total: k.total,
                       alCredito: alCredito, vence: vence, estado: estado,
                       pagada: !alCredito,   // contado: queda pagada
                       comprador: comprador, proveedor: proveedor, producto: producto)
        ctx.insert(c)
        if estado == Estado.aprobada { aplicarEfectos(c) }
        try? ctx.save()
        return c
    }

    // Lo que se le debe a un proveedor: compras aprobadas, a crédito y no pagadas
    static func porPagar(_ p: Proveedor) -> Double {
        p.compras.filter { $0.estado == Estado.aprobada && $0.alCredito && !$0.pagada }.reduce(0) { $0 + $1.total }
    }

    // Total comprado al proveedor (solo aprobadas)
    static func totalComprado(_ p: Proveedor) -> Double {
        p.compras.filter { $0.estado == Estado.aprobada }.reduce(0) { $0 + $1.total }
    }
}

// MARK: - Sesión (recuerda al usuario mientras la app está abierta)

@Observable
final class Sesion {
    var usuario: Usuario?
    var esSupervisor: Bool { usuario?.rol == Rol.supervisor }
}

// MARK: - Formato y colores

let verde = Color(red: 0.05, green: 0.55, blue: 0.45)

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
    var corta: String { formatted(.dateTime.day(.twoDigits).month(.twoDigits).year()) }
}

func iniciales(_ nombre: String) -> String {
    nombre.split(separator: " ").prefix(2).compactMap { $0.first.map(String.init) }.joined().uppercased()
}

// MARK: - Datos de prueba (solo la primera vez)

enum DatosIniciales {
    static func cargar(_ ctx: ModelContext) {
        let cuantos = (try? ctx.fetchCount(FetchDescriptor<Producto>())) ?? 0
        guard cuantos == 0 else { return }

        let marco = Usuario(nombre: "Marco Torres", usuario: "mtorres2", clave: "123456", rol: Rol.comprador)
        let rosa = Usuario(nombre: "Rosa Vega", usuario: "rvega", clave: "123456", rol: Rol.comprador)
        let lucia = Usuario(nombre: "Lucía Paredes", usuario: "supervisor", clave: "123456", rol: Rol.supervisor)
        [marco, rosa, lucia].forEach { ctx.insert($0) }

        // Caso 3: stock 40 y costo promedio 110.00
        let laptop = Producto(nombre: "Laptop Pro 14", categoria: "Laptops", stock: 40, costoPromedio: 110.00)
        let monitor = Producto(nombre: "Monitor 24\"", categoria: "Monitores", stock: 9, costoPromedio: 300.00)
        let mouse = Producto(nombre: "Mouse inalámbrico", categoria: "Accesorios", stock: 120, costoPromedio: 18.50)
        let teclado = Producto(nombre: "Teclado mecánico", categoria: "Accesorios", stock: 4, costoPromedio: 80.00)
        [laptop, monitor, mouse, teclado].forEach { ctx.insert($0) }

        let lima = Proveedor(nombre: "Distribuidora Lima SAC", ruc: "20100000011")
        let tecno = Proveedor(nombre: "TecnoImport EIRL", ruc: "20100000012")
        let sur = Proveedor(nombre: "Mayorista Sur SAC", ruc: "20100000013")
        [lima, tecno, sur].forEach { ctx.insert($0) }

        // Historial (se inserta directo para no alterar el stock y costo del caso 3)
        let cal = Calendar.current
        func hace(_ d: Int) -> Date { cal.date(byAdding: .day, value: -d, to: Date())! }
        func historica(_ dias: Int, _ u: Usuario, _ prov: Proveedor, _ prod: Producto, _ cant: Int, _ costo: Double,
                       credito: Bool, pagada: Bool, estado: String = Estado.aprobada, motivo: String? = nil) {
            let k = Reglas.calcular(cantidad: cant, costo: costo)
            let f = hace(dias)
            let c = Compra(fecha: f, cantidad: cant, costoUnitario: costo, igv: k.igv, total: k.total,
                           alCredito: credito, vence: cal.date(byAdding: .day, value: 30, to: f)!,
                           estado: estado, pagada: pagada, comprador: u, proveedor: prov, producto: prod)
            c.motivoRechazo = motivo
            ctx.insert(c)
        }
        historica(40, marco, tecno, mouse, 100, 18.50, credito: true, pagada: false)   // VENCIDA (caso 8)
        historica(12, rosa, sur, monitor, 5, 300.00, credito: true, pagada: false)     // por pagar, al día
        historica(20, marco, lima, laptop, 10, 110.00, credito: false, pagada: true)   // contado
        historica(8, rosa, lima, teclado, 10, 80.00, credito: true, pagada: true)      // crédito ya pagado
        historica(5, marco, sur, monitor, 20, 310.00, credito: true, pagada: false,
                  estado: Estado.rechazada, motivo: "Precio por encima del mercado")
        try? ctx.save()
    }
}
