//
//  SupervisorViews.swift
//  B7 · Aprobar · B8 · Por pagar · B9 · Resumen (solo supervisor)
//

import SwiftUI
import SwiftData

// MARK: - B7 · Aprobar

struct AprobarView: View {
    @Environment(\.modelContext) private var ctx
    // #Predicate: solo las compras Pendientes de aprobación
    @Query(filter: #Predicate<Compra> { $0.estado == "Pendiente" }, sort: \Compra.fecha)
    private var pendientes: [Compra]
    @State private var rechazando: Compra?
    @State private var motivo = ""

    var body: some View {
        List {
            Section {
                ForEach(pendientes) { c in
                    TarjetaAprobacion(compra: c,
                                      aprobar: { aprobar(c) },
                                      rechazar: { motivo = ""; rechazando = c })
                }
            } footer: {
                Text("Al rechazar se pide un motivo, que el comprador verá en \"Mis compras\".")
            }
        }
        .overlay { if pendientes.isEmpty { ContentUnavailableView("Nada por aprobar", systemImage: "checkmark.seal") } }
        .navigationTitle("Aprobar")
        .conAvatar()
        // ④ Rechazar pide motivo (botón deshabilitado si está vacío)
        .alert("Rechazar compra", isPresented: .constant(rechazando != nil)) {
            TextField("Motivo (obligatorio)", text: $motivo)
            Button("Cancelar", role: .cancel) { rechazando = nil }
            Button("Rechazar", role: .destructive) {
                if let c = rechazando { rechazar(c) }
                rechazando = nil
            }
            .disabled(motivo.trimmingCharacters(in: .whitespaces).isEmpty)
        } message: {
            Text("La compra no cambiará stock ni costo promedio.")
        }
    }

    // Aprobar: aplica efectos (stock y costo promedio) y pasa a "Aprobada"
    func aprobar(_ c: Compra) {
        Reglas.aplicarEfectos(c)
        c.estado = Estado.aprobada
        try? ctx.save()
    }

    // Rechazar: guarda el motivo; no cambia nada más
    func rechazar(_ c: Compra) {
        let m = motivo.trimmingCharacters(in: .whitespaces)
        guard !m.isEmpty else { return }
        c.estado = Estado.rechazada
        c.motivoRechazo = m
        try? ctx.save()
    }
}

struct TarjetaAprobacion: View {
    let compra: Compra
    let aprobar: () -> Void
    let rechazar: () -> Void

    var body: some View {
        let p = compra.producto
        let stockAntes = p?.stock ?? 0
        let costoAntes = p?.costoPromedio ?? 0
        let costoDespues = Reglas.nuevoCostoPromedio(stock: stockAntes, costoProm: costoAntes,
                                                     cantidad: compra.cantidad, costo: compra.costoUnitario)
        VStack(alignment: .leading, spacing: 8) {
            // ② Tarjeta con quién la solicitó
            HStack {
                Text("\(compra.proveedor?.nombre ?? "") · \(p?.nombre ?? "")").font(.headline)
                Spacer()
                Insignia(texto: "Pendiente", color: .orange)
            }
            Text("Solicitó: \(compra.comprador?.nombre ?? "—") · \(compra.fecha.corta)")
                .font(.caption).foregroundStyle(.secondary)
            Text("\(compra.cantidad) u. × \(compra.costoUnitario.soles) = \(compra.subtotal.soles)")
            Text("IGV 18% \(compra.igv.soles) · **Total \(compra.total.soles)**")
            Text(compra.alCredito ? "Crédito 30 días · vence \(compra.vence.corta)" : "Contado")
                .font(.caption).foregroundStyle(.secondary)

            // ③ Vista previa del efecto
            VStack(alignment: .leading, spacing: 2) {
                Text("Si apruebas:").font(.caption).foregroundStyle(.secondary)
                Text("stock **\(stockAntes) → \(stockAntes + compra.cantidad)**")
                Text("costo promedio **\(costoAntes.soles) → \(costoDespues.soles)**")
            }
            .font(.subheadline)
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10))

            // ④ Rechazar o Aprobar
            HStack {
                Button("Rechazar", role: .destructive, action: rechazar)
                    .buttonStyle(.bordered).frame(maxWidth: .infinity)
                Button("Aprobar", action: aprobar)
                    .buttonStyle(.borderedProminent).frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 6)
    }
}

// MARK: - B8 · Por pagar

struct PorPagarView: View {
    @State private var filtro = 0
    @State private var busqueda = ""

    var body: some View {
        VStack(spacing: 0) {
            Picker("Filtro", selection: $filtro) {                               // ① Segmented
                Text("Pendientes").tag(0)
                Text("Vencidas").tag(1)
                Text("Pagadas").tag(2)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal).padding(.bottom, 6)
            ListaPorPagar(filtro: filtro, busqueda: busqueda)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Por pagar")
        .searchable(text: $busqueda, prompt: "Buscar por proveedor")
        .conAvatar()
    }
}

struct ListaPorPagar: View {
    @Environment(Sesion.self) private var sesion
    @Environment(\.modelContext) private var ctx
    @Query private var compras: [Compra]
    let filtro: Int
    let busqueda: String

    // #Predicate de Pendientes / Vencidas / Pagadas (solo compras aprobadas a crédito)
    init(filtro: Int, busqueda: String) {
        self.filtro = filtro
        self.busqueda = busqueda
        let aprobada = Estado.aprobada
        let ahora = Date()
        let predicado: Predicate<Compra>
        switch filtro {
        case 1: predicado = #Predicate { $0.estado == aprobada && $0.alCredito == true && $0.pagada == false && $0.vence < ahora }
        case 2: predicado = #Predicate { $0.estado == aprobada && $0.alCredito == true && $0.pagada == true }
        default: predicado = #Predicate { $0.estado == aprobada && $0.alCredito == true && $0.pagada == false }
        }
        _compras = Query(filter: predicado, sort: \Compra.vence)
    }

    var filtradas: [Compra] {
        busqueda.isEmpty ? compras
            : compras.filter { ($0.proveedor?.nombre ?? "").localizedCaseInsensitiveContains(busqueda) }
    }

    var body: some View {
        List {
            Section {
                ForEach(filtradas) { c in
                    NavigationLink { OrdenCompraView(compra: c) } label: {
                        FilaCompra(compra: c)                                     // ② ③ VENCIDA
                    }
                    .swipeActions(edge: .trailing) {                              // ④ Deslizar Pagar (supervisor)
                        if sesion.esSupervisor && !c.pagada {
                            Button("Pagar") {
                                c.pagada = true
                                try? ctx.save()
                            }
                            .tint(.green)
                        }
                    }
                }
            } footer: {
                Text("Solo cuentan compras aprobadas a crédito y no pagadas.")
            }
            if filtro != 2 {
                Section("Total por pagar") {                                      // ⑤ Total por pagar
                    Text(filtradas.reduce(0) { $0 + $1.total }.soles).font(.title2.bold())
                }
            }
        }
        .overlay { if filtradas.isEmpty { ContentUnavailableView("Sin compras", systemImage: "tray") } }
    }
}

// MARK: - B9 · Resumen (Reto)

struct ResumenView: View {
    @Environment(Sesion.self) private var sesion
    @Query private var productos: [Producto]
    @Query(filter: #Predicate<Compra> { $0.estado == "Aprobada" }) private var aprobadas: [Compra]
    @Query(filter: #Predicate<Compra> { $0.estado == "Pendiente" }) private var porAprobar: [Compra]
    @Query(sort: \Proveedor.nombre) private var proveedores: [Proveedor]

    var inventario: Double { productos.reduce(0) { $0 + Double($1.stock) * $1.costoPromedio } }
    var creditoFiscal: Double { aprobadas.reduce(0) { $0 + $1.igv } }
    var porPagar: Double { aprobadas.filter { $0.alCredito && !$0.pagada }.reduce(0) { $0 + $1.total } }
    var montoPorAprobar: Double { porAprobar.reduce(0) { $0 + $1.total } }

    var ranking: [(String, Double)] {
        proveedores.map { ($0.nombre, Reglas.totalComprado($0)) }.sorted { $0.1 > $1.1 }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Hola, \(sesion.usuario?.nombre.split(separator: " ").first.map(String.init) ?? "")")
                    .font(.title2.bold())

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    Indicador(titulo: "Inventario", valor: inventario.soles)                 // ②
                    Indicador(titulo: "Crédito fiscal (IGV)", valor: creditoFiscal.soles)    // ③
                    Indicador(titulo: "Por pagar", valor: porPagar.soles)
                    Indicador(titulo: "Por aprobar", valor: "\(porAprobar.count)",           // ④
                              detalle: montoPorAprobar.soles, color: .orange)
                }

                // ⑤ Total comprado por proveedor con barras
                VStack(alignment: .leading, spacing: 10) {
                    Text("Total comprado por proveedor").font(.subheadline).foregroundStyle(.secondary)
                    let maximo = max(ranking.first?.1 ?? 1, 1)
                    ForEach(ranking, id: \.0) { nombre, total in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("**\(nombre)** · \(total.soles)").font(.subheadline)
                            ProgressView(value: total, total: maximo).tint(verde)
                        }
                    }
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Resumen")
        .conAvatar()                                                                 // ①
    }
}

struct Indicador: View {
    let titulo: String
    let valor: String
    var detalle: String?
    var color: Color = .primary

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(titulo).font(.caption).foregroundStyle(.secondary)
            Text(valor).font(.title3.bold()).foregroundStyle(color).minimumScaleFactor(0.6).lineLimit(1)
            if let detalle { Text(detalle).font(.caption).foregroundStyle(color) }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
    }
}
