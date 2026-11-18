//
//  DatosIniciales.swift
//  Datos de prueba que se cargan solo la primera vez (BD vacía).
//

import Foundation
import CoreData

enum DatosIniciales {

    static func cargarSiEstaVacio(en ctx: NSManagedObjectContext) {
        let request = NSFetchRequest<Producto>(entityName: "Producto")
        guard ((try? ctx.count(for: request)) ?? 0) == 0 else { return }

        // Usuarios de prueba (clave 123456)
        let carlos = usuario(ctx, "Carlos Ruiz", "cruiz", Rol.vendedor)
        let ana = usuario(ctx, "Ana Díaz", "adiaz", Rol.vendedor)
        _ = usuario(ctx, "Lucía Supervisora", "supervisor", Rol.supervisor)

        // Productos (caso 4: Laptop S/ 200 con stock 40 · caso 5: Mouse S/ 35)
        let laptop = producto(ctx, "Laptop Pro 14", "Laptops", 200.00, 40)
        let monitor = producto(ctx, "Monitor 24\"", "Monitores", 450.00, 8)
        _ = producto(ctx, "Mouse inalámbrico", "Accesorios", 35.00, 120)
        let teclado = producto(ctx, "Teclado mecánico", "Accesorios", 129.90, 4)

        // Clientes
        let andina = cliente(ctx, "Comercial Andina SAC", "RUC 20001230001")
        let maria = cliente(ctx, "María Quispe", "DNI 40000001")
        _ = cliente(ctx, "Luis Rojas", "DNI 40000002")
        _ = cliente(ctx, "Tienda Sol EIRL", "RUC 20004560044")

        // Ventas históricas (no descuentan stock: el stock de arriba es el actual).
        // Hacen que "Comercial Andina SAC" sea VIP (> S/ 5,000) y María Frecuente.
        let cal = Calendar.current
        func hace(_ dias: Int, _ hora: Int = 11) -> Date {
            let d = cal.date(byAdding: .day, value: -dias, to: Date())!
            return cal.date(bySettingHour: hora, minute: 0, second: 0, of: d)!
        }
        venta(ctx, hace(6), carlos, monitor, andina, 4, .regular)       // 2,124.00
        venta(ctx, hace(5), ana, monitor, andina, 3, .frecuente)        // 1,593.00
        venta(ctx, hace(4), carlos, laptop, andina, 7, .frecuente)      // 1,652.00
        venta(ctx, hace(3), ana, laptop, maria, 5, .regular)            // 1,180.00
        venta(ctx, hace(2), carlos, teclado, maria, 1, .frecuente)      //   153.28
        venta(ctx, hace(1), ana, monitor, maria, 1, .frecuente)         //   531.00

        try? ctx.save()
    }

    private static func usuario(_ ctx: NSManagedObjectContext, _ nombre: String, _ user: String, _ rol: String) -> Usuario {
        let u = Usuario(context: ctx)
        u.nombre = nombre; u.usuario = user; u.clave = "123456"; u.rol = rol
        return u
    }

    private static func producto(_ ctx: NSManagedObjectContext, _ nombre: String, _ cat: String, _ precio: Double, _ stock: Int64) -> Producto {
        let p = Producto(context: ctx)
        p.nombre = nombre; p.categoria = cat; p.precio = precio; p.stock = stock
        return p
    }

    private static func cliente(_ ctx: NSManagedObjectContext, _ nombre: String, _ doc: String) -> Cliente {
        let c = Cliente(context: ctx)
        c.nombre = nombre; c.documento = doc
        return c
    }

    private static func venta(_ ctx: NSManagedObjectContext, _ fecha: Date, _ vendedor: Usuario, _ producto: Producto,
                              _ cliente: Cliente, _ cantidad: Int, _ cat: CategoriaCliente) {
        let calc = Reglas.calcular(precio: producto.precio, cantidad: cantidad, categoria: cat)
        let v = Venta(context: ctx)
        v.fecha = fecha
        v.cantidad = Int64(cantidad)
        v.precioUnitario = producto.precio
        v.descuento = calc.descuento
        v.igv = calc.igv
        v.total = calc.total
        v.vendedor = vendedor
        v.producto = producto
        v.cliente = cliente
    }
}
