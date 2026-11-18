//
//  CompraViews.swift
//  B5 · Nueva compra (comprador) y B6 · Mis compras
//

import SwiftUI
import SwiftData

// MARK: - B5 · Nueva compra

struct NuevaCompraView: View {
    @Environment(Sesion.self) private var sesion
    @Environment(\.modelContext) private var ctx
    @Query(sort: \Proveedor.nombre) private var proveedores: [Proveedor]
    @Query(sort: \Producto.nombre) private var productos: [Producto]

    @State private var proveedor: Proveedor?
    @State private var producto: Producto?
    @State private var cantidad = 1
    @State private var costo = 0.0
    @State private var alCredito = false
    @State private var registrada: Compra?

    var calculo: (subtotal: Double, igv: Double, total: Double) { Reglas.calcular(cantidad: cantidad, costo: costo) }
    var requiereAprobacion: Bool { calculo.total >= Reglas.limiteAprobacion }
    var valido: Bool { proveedor != nil && producto != nil && cantidad > 0 && costo > 0 }

    var body: some View {
        Form {
            Section {
                Picker("Proveedor", selection: $proveedor) {                     // ② Proveedor
                    Text("Elegir").tag(Proveedor?.none)
                    ForEach(proveedores) { Text($0.nombre).tag(Optional($0)) }
                }
                Picker("Producto", selection: $producto) {                       // ③ Producto
                    Text("Elegir").tag(Producto?.none)
                    ForEach(productos) { Text($0.nombre).tag(Optional($0)) }
                }
                .onChange(of: producto) { _, p in if let p { costo = p.costoPromedio } }
                HStack {                                                         // ④ Cantidad
                    Text("Cantidad")
                    Spacer()
                    TextField("0", value: $cantidad, format: .number)
                        .keyboardType(.numberPad).multilineTextAlignment(.trailing).frame(width: 80)
                }
                HStack {
                    Text("Costo unitario")
                    Spacer()
                    TextField("0.00", value: $costo, format: .number.precision(.fractionLength(2)))
                        .keyboardType(.decimalPad).multilineTextAlignment(.trailing).frame(width: 100)
                }
                if let p = producto {
                    Text("Stock actual \(p.stock) · costo promedio \(p.costoPromedio.soles)")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }

            Section {                                                            // ⑤ Contado o Crédito
                Picker("Pago", selection: $alCredito) {
                    Text("Contado").tag(false)
                    Text("Crédito 30 días").tag(true)
                }
                .pickerStyle(.segmented)
            }

            Section("Resumen") {
                LabeledContent("Subtotal", value: calculo.subtotal.soles)
                LabeledContent("IGV 18% (crédito fiscal)", value: calculo.igv.soles)
                LabeledContent("Total") { Text(calculo.total.soles).bold() }
            }

            if requiereAprobacion {                                              // ⑥ Aviso desde S/ 5,000
                Section {
                    Label("Supera S/ 5,000: quedará **pendiente de aprobación** del supervisor. No cambia stock ni costo promedio todavía.",
                          systemImage: "exclamationmark.triangle.fill")
                        .font(.footnote)
                        .listRowBackground(Color.yellow.opacity(0.2))
                }
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .safeAreaInset(edge: .bottom) {                                          // ⑦ Botón siempre visible
            Button { registrar() } label: {
                Text(requiereAprobacion ? "Enviar a aprobación" : "Registrar compra").frame(maxWidth: .infinity).bold()
            }
            .buttonStyle(.borderedProminent).controlSize(.large)
            .disabled(!valido)
            .padding(.horizontal).padding(.bottom, 8)
        }
        .navigationTitle("Nueva compra")
        .conAvatar()                                                             // ① Avatar de la sesión
        .sheet(item: $registrada) { c in
            NavigationStack { OrdenCompraView(compra: c, recienRegistrada: true) }
        }
    }

    func registrar() {
        guard let u = sesion.usuario, let proveedor, let producto else { return }
        let c = Reglas.registrar(en: ctx, comprador: u, proveedor: proveedor, producto: producto,
                                 cantidad: cantidad, costo: costo, alCredito: alCredito)
        registrada = c
        self.producto = nil
        self.proveedor = nil
        cantidad = 1
        costo = 0
        alCredito = false
    }
}

// MARK: - B6 · Mis compras (el comprador solo ve las suyas)

struct MisComprasView: View {
    @Environment(Sesion.self) private var sesion
    @State private var filtro = 0
    @State private var busqueda = ""

    var body: some View {
        VStack(spacing: 0) {
            Picker("Filtro", selection: $filtro) {                               // ① Segmented
                Text("Todas").tag(0)
                Text("Pendientes").tag(1)
                Text("Rechazadas").tag(2)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal).padding(.bottom, 6)

            ListaMisCompras(usuario: sesion.usuario?.usuario ?? "", filtro: filtro, busqueda: busqueda)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Mis compras")
        .searchable(text: $busqueda, prompt: "Buscar por proveedor")
        .conAvatar()
    }
}

struct ListaMisCompras: View {
    @Query private var compras: [Compra]
    let busqueda: String

    // #Predicate por comprador (relación compra ▸ comprador) y por estado
    init(usuario: String, filtro: Int, busqueda: String) {
        self.busqueda = busqueda
        let pendiente = Estado.pendiente
        let rechazada = Estado.rechazada
        let predicado: Predicate<Compra>
        switch filtro {
        case 1: predicado = #Predicate { $0.comprador?.usuario == usuario && $0.estado == pendiente }
        case 2: predicado = #Predicate { $0.comprador?.usuario == usuario && $0.estado == rechazada }
        default: predicado = #Predicate { $0.comprador?.usuario == usuario }
        }
        _compras = Query(filter: predicado, sort: \Compra.fecha, order: .reverse)
    }

    var filtradas: [Compra] {
        busqueda.isEmpty ? compras
            : compras.filter { ($0.proveedor?.nombre ?? "").localizedCaseInsensitiveContains(busqueda) }
    }

    var body: some View {
        List {
            Section {
                ForEach(filtradas) { c in
                    NavigationLink { OrdenCompraView(compra: c) } label: { FilaCompra(compra: c) }
                }
            } footer: {
                Text("El comprador solo ve sus compras; no puede pagar ni aprobar.")    // ④
            }
        }
        .overlay { if filtradas.isEmpty { ContentUnavailableView("Sin compras", systemImage: "tray") } }
    }
}

// Fila de compra reutilizable: ② pendiente · ③ rechazada con su motivo
struct FilaCompra: View {
    let compra: Compra
    var mostrarComprador = false

    var icono: String {
        switch compra.estado {
        case Estado.pendiente: return "hourglass"
        case Estado.rechazada: return "xmark"
        default: return "checkmark"
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icono)
                .font(.headline).foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(colorEstado(compra), in: RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 2) {
                Text(compra.proveedor?.nombre ?? "—").font(.headline).lineLimit(1)
                Text("\(compra.producto?.nombre ?? "") × \(compra.cantidad) · \(compra.fecha.corta)")
                    .font(.caption).foregroundStyle(.secondary).lineLimit(1)
                if mostrarComprador {
                    Text("Solicitó: \(compra.comprador?.nombre ?? "—")").font(.caption).foregroundStyle(.secondary)
                }
                if compra.estado == Estado.rechazada, let m = compra.motivoRechazo {
                    Text("Motivo: \(m)").font(.caption).foregroundStyle(.red).lineLimit(2)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(compra.total.soles).font(.subheadline.bold())
                if compra.vencida {
                    Insignia(texto: "VENCIDA", color: .red)
                } else {
                    Insignia(texto: compra.estado, color: colorEstado(compra))
                }
            }
        }
    }
}
