//
//  OrdenCompraView.swift
//  VALOR AGREGADO · Orden de compra compartible en PDF.
//  Todo se lee de la compra y sus relaciones: compra ▸ proveedor, producto y comprador.
//

import SwiftUI
import SwiftData

struct OrdenCompraView: View {
    @Environment(\.dismiss) private var dismiss
    let compra: Compra
    var recienRegistrada = false
    @State private var urlPDF: URL?

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if recienRegistrada {
                    Label(compra.estado == Estado.aprobada ? "Compra registrada y aprobada"
                                                           : "Enviada a aprobación del supervisor",
                          systemImage: compra.estado == Estado.aprobada ? "checkmark.circle.fill" : "hourglass")
                        .font(.headline)
                        .foregroundStyle(colorEstado(compra))
                }
                TicketOrden(compra: compra)
                if let urlPDF {
                    ShareLink(item: urlPDF) {
                        Label("Compartir orden (PDF)", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent).controlSize(.large)
                }
            }
            .padding()
        }
        .background(FondoElegante())
        .navigationTitle("Orden de compra")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if recienRegistrada {
                ToolbarItem(placement: .cancellationAction) { Button("Cerrar") { dismiss() } }
            }
        }
        .onAppear { urlPDF = generarPDF() }
    }

    // ImageRenderer dibuja la vista SwiftUI dentro de una página PDF
    @MainActor
    func generarPDF() -> URL? {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("Orden-\(TicketOrden.numero(compra)).pdf")
        let renderer = ImageRenderer(content: TicketOrden(compra: compra).frame(width: 380).padding(20).background(.white))
        var ok = false
        renderer.render { size, dibujar in
            var caja = CGRect(origin: .zero, size: size)
            guard let pdf = CGContext(url as CFURL, mediaBox: &caja, nil) else { return }
            pdf.beginPDFPage(nil)
            dibujar(pdf)
            pdf.endPDFPage()
            pdf.closePDF()
            ok = true
        }
        return ok ? url : nil
    }
}

struct TicketOrden: View {
    let compra: Compra

    // Número a partir del id persistente (…/p7 → OC-000007)
    static func numero(_ c: Compra) -> String {
        let texto = "\(c.persistentModelID.hashValue)"
        let digitos = String(texto.filter(\.isNumber).suffix(6))
        return "OC-" + String(repeating: "0", count: max(0, 6 - digitos.count)) + digitos
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            VStack(spacing: 4) {
                Image(systemName: "shippingbox.fill").font(.title).foregroundStyle(verde)
                Text("Compras Tecsup").font(.system(.title3, design: .serif).bold())
                Text("Orden de compra \(Self.numero(compra))").font(.subheadline).foregroundStyle(.gray)
            }
            .frame(maxWidth: .infinity)
            separador
            fila("Fecha", compra.fecha.formatted(date: .numeric, time: .shortened))
            fila("Comprador", compra.comprador?.nombre ?? "—")
            fila("Proveedor", compra.proveedor?.nombre ?? "—")
            fila("RUC", compra.proveedor?.ruc ?? "—")
            fila("Pago", compra.alCredito ? "Crédito 30 días" : "Contado")
            if compra.alCredito { fila("Vence", compra.vence.corta) }
            separador
            Text(compra.producto?.nombre ?? "—").font(.headline)
            fila("\(compra.cantidad) × \(compra.costoUnitario.soles)", compra.subtotal.soles)
            separador
            fila("Subtotal", compra.subtotal.soles)
            fila("IGV 18% (crédito fiscal)", compra.igv.soles)
            HStack { Text("TOTAL").bold(); Spacer(); Text(compra.total.soles).bold() }.font(.title3)
            separador
            HStack {
                Text("Estado").foregroundStyle(.gray)
                Spacer()
                Insignia(texto: compra.vencida ? "VENCIDA" : compra.estado,
                         color: compra.vencida ? .red : colorEstado(compra))
                if compra.alCredito && compra.estado == Estado.aprobada {
                    Insignia(texto: compra.pagada ? "Pagada" : "Por pagar", color: compra.pagada ? .green : .red)
                }
            }
            if let m = compra.motivoRechazo {
                Text("Motivo de rechazo: \(m)").font(.footnote).foregroundStyle(.red)
            }
        }
        .padding(20)
        .foregroundStyle(.black)
        .background(.white, in: RoundedRectangle(cornerRadius: 16))
        .environment(\.colorScheme, .light)
    }

    var separador: some View {
        Text(String(repeating: "- ", count: 40)).font(.caption2).foregroundStyle(.gray.opacity(0.5)).lineLimit(1)
    }

    func fila(_ a: String, _ b: String) -> some View {
        HStack { Text(a).foregroundStyle(.gray); Spacer(); Text(b).fontWeight(.medium) }.font(.subheadline)
    }
}
