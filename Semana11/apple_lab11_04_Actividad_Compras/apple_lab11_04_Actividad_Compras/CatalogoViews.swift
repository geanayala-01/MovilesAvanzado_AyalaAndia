//
//  CatalogoViews.swift
//  B3 · Productos y B4 · Proveedores
//

import SwiftUI
import SwiftData

// MARK: - B3 · Productos

struct ProductosView: View {
    @Environment(Sesion.self) private var sesion
    @Environment(\.modelContext) private var ctx
    @Query(sort: \Producto.nombre) private var productos: [Producto]
    @State private var busqueda = ""
    @State private var editando: Producto?
    @State private var creando = false
    @State private var aviso: String?

    var filtrados: [Producto] {
        busqueda.isEmpty ? productos : productos.filter { $0.nombre.localizedCaseInsensitiveContains(busqueda) }
    }

    // ④ Valor del inventario = Σ stock × costo promedio
    var valorInventario: Double { productos.reduce(0) { $0 + Double($1.stock) * $1.costoPromedio } }

    var body: some View {
        List {
            Section {
                ForEach(filtrados) { p in
                    // ③ Fila con costo promedio y stock en color
                    FilaProducto(producto: p)
                        .contentShape(Rectangle())
                        .onTapGesture { if sesion.esSupervisor { editando = p } }
                }
                // ⑤ Deslizar para borrar (solo supervisor; bloqueado si tiene compras → .deny)
                .onDelete(perform: borrar)
                .deleteDisabled(!sesion.esSupervisor)
            } footer: {
                Text(sesion.esSupervisor ? "Desliza para borrar (.onDelete): bloqueado si tiene compras."
                                         : "Vista del comprador: solo consulta.")
            }

            Section("Valor del inventario (stock × costo promedio)") {
                Text(valorInventario.soles).font(.system(.title, design: .serif).bold()).foregroundStyle(verde)
            }
        }
        .fondoElegante()
        .navigationTitle("Productos")
        .searchable(text: $busqueda, prompt: "Buscar")                  // ② Búsqueda
        .toolbar {
            if sesion.esSupervisor {                                      // ① Botón + solo supervisor
                ToolbarItem(placement: .topBarLeading) {
                    Button("Nuevo", systemImage: "plus") { creando = true }
                }
            }
        }
        .conAvatar()
        .sheet(isPresented: $creando) { ProductoForm(producto: nil) }
        .sheet(item: $editando) { ProductoForm(producto: $0) }
        .alert("No se puede borrar", isPresented: .constant(aviso != nil)) {
            Button("OK") { aviso = nil }
        } message: { Text(aviso ?? "") }
    }

    func borrar(_ indices: IndexSet) {
        for i in indices {
            let p = filtrados[i]
            if !p.compras.isEmpty {
                aviso = "\"\(p.nombre)\" tiene compras registradas (.deny)."
                continue
            }
            ctx.delete(p)
        }
        try? ctx.save()
    }
}

struct ProductoForm: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var ctx
    let producto: Producto?
    @State private var nombre = ""
    @State private var categoria = ""
    @State private var stock = 0
    @State private var costo = 0.0

    var body: some View {
        NavigationStack {
            Form {
                TextField("Nombre", text: $nombre)
                TextField("Categoría", text: $categoria)
                Stepper("Stock: \(stock)", value: $stock, in: 0...10000)
                HStack {
                    Text("Costo promedio")
                    TextField("0.00", value: $costo, format: .number).keyboardType(.decimalPad).multilineTextAlignment(.trailing)
                }
            }
            .navigationTitle(producto == nil ? "Nuevo producto" : "Editar producto")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        let p = producto ?? Producto(nombre: "", categoria: "", stock: 0, costoPromedio: 0)
                        p.nombre = nombre; p.categoria = categoria; p.stock = stock; p.costoPromedio = costo
                        if producto == nil { ctx.insert(p) }
                        try? ctx.save()
                        dismiss()
                    }
                    .disabled(nombre.isEmpty || categoria.isEmpty || costo <= 0)
                }
            }
            .onAppear {
                if let p = producto { nombre = p.nombre; categoria = p.categoria; stock = p.stock; costo = p.costoPromedio }
            }
        }
    }
}

// MARK: - B4 · Proveedores

struct ProveedoresView: View {
    @Environment(Sesion.self) private var sesion
    @Environment(\.modelContext) private var ctx
    @Query(sort: \Proveedor.nombre) private var proveedores: [Proveedor]
    @State private var busqueda = ""
    @State private var editando: Proveedor?
    @State private var creando = false
    @State private var aviso: String?

    var filtrados: [Proveedor] {
        busqueda.isEmpty ? proveedores
            : proveedores.filter { $0.nombre.localizedCaseInsensitiveContains(busqueda) || $0.ruc.contains(busqueda) }
    }

    var body: some View {
        List {
            Section {
                ForEach(filtrados) { p in
                    // ② Fila con insignia "por pagar" o "Al día" y total comprado
                    FilaProveedor(proveedor: p)
                        .contentShape(Rectangle())
                        .onTapGesture { if sesion.esSupervisor { editando = p } }
                }
                .onDelete(perform: borrar)
                .deleteDisabled(!sesion.esSupervisor)
            } footer: {
                // ③ Nota: valores calculados desde las compras (relación proveedor ▸ compras)
                Text("\"Por pagar\" y \"comprado\" se calculan con las compras del proveedor (relación proveedor ▸ compras).")
            }
        }
        .fondoElegante()
        .navigationTitle("Proveedores")
        .searchable(text: $busqueda, prompt: "Buscar por nombre o RUC")
        .toolbar {
            if sesion.esSupervisor {                                       // ① Botón + solo supervisor
                ToolbarItem(placement: .topBarLeading) {
                    Button("Nuevo", systemImage: "plus") { creando = true }
                }
            }
        }
        .conAvatar()
        .sheet(isPresented: $creando) { ProveedorForm(proveedor: nil) }
        .sheet(item: $editando) { ProveedorForm(proveedor: $0) }
        .alert("No se puede borrar", isPresented: .constant(aviso != nil)) {
            Button("OK") { aviso = nil }
        } message: { Text(aviso ?? "") }
    }

    func borrar(_ indices: IndexSet) {
        for i in indices {
            let p = filtrados[i]
            if !p.compras.isEmpty { aviso = "\"\(p.nombre)\" tiene compras registradas (.deny)."; continue }
            ctx.delete(p)
        }
        try? ctx.save()
    }
}

struct ProveedorForm: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var ctx
    let proveedor: Proveedor?
    @State private var nombre = ""
    @State private var ruc = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Razón social", text: $nombre)
                TextField("RUC (11 dígitos)", text: $ruc).keyboardType(.numberPad)
            }
            .navigationTitle(proveedor == nil ? "Nuevo proveedor" : "Editar proveedor")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        let p = proveedor ?? Proveedor(nombre: "", ruc: "")
                        p.nombre = nombre; p.ruc = ruc
                        if proveedor == nil { ctx.insert(p) }
                        try? ctx.save()
                        dismiss()
                    }
                    .disabled(nombre.isEmpty || ruc.count != 11)
                }
            }
            .onAppear { if let p = proveedor { nombre = p.nombre; ruc = p.ruc } }
        }
    }
}

// MARK: - Filas

struct FilaProducto: View {
    let producto: Producto
    var colorStock: Color { producto.stock > 10 ? .green : (producto.stock >= 6 ? .orange : .red) }

    var body: some View {
        HStack(spacing: 12) {
            Iniciales(nombre: producto.nombre)
            VStack(alignment: .leading) {
                Text(producto.nombre).font(.headline).lineLimit(1)
                Text(producto.categoria).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(producto.costoPromedio.soles).font(.subheadline.bold())
                Text("costo prom.").font(.caption2).foregroundStyle(.secondary)
            }
            Insignia(texto: "\(producto.stock) u.", color: colorStock)
        }
    }
}

struct FilaProveedor: View {
    let proveedor: Proveedor

    var body: some View {
        let deuda = Reglas.porPagar(proveedor)
        HStack(spacing: 12) {
            Iniciales(nombre: proveedor.nombre, color: .indigo)
            VStack(alignment: .leading) {
                Text(proveedor.nombre).font(.headline).lineLimit(1)
                Text("RUC \(proveedor.ruc)").font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(Reglas.totalComprado(proveedor).soles).font(.subheadline.bold())
                Insignia(texto: deuda > 0 ? "Por pagar \(deuda.soles)" : "Al día", color: deuda > 0 ? .red : .green)
            }
        }
    }
}
