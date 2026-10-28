import SwiftUI

// PANTALLA 2: muestra el resultado paso a paso (bloques 2 y 3 del Excel)
struct ResultadoView: View {
    let datos: DatosCTS

    var body: some View {
        List {
            // Tarjeta con el total
            Section {
                VStack(spacing: 8) {
                    Image(systemName: "banknote.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.green)
                    Text("CTS a depositar")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text(soles(datos.ctsTotal))
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(.green)
                    Text("\(datos.trabajador) · se deposita en \(datos.mesDeposito)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
            }

            Section("Remuneración computable") {
                Fila(titulo: "Sueldo básico", valor: datos.sueldo)
                Fila(titulo: "Asignación familiar", detalle: "10% de la RMV", valor: datos.asignacionFamiliar)
                Fila(titulo: "Promedio horas extras",
                     detalle: datos.horasExtrasRegulares
                        ? "Regulares: \(datos.mesesConHorasExtras) meses"
                        : "No cuentan: solo \(datos.mesesConHorasExtras) meses",
                     valor: datos.promedioHorasExtras)
                Fila(titulo: "1/6 de la gratificación", detalle: "\(soles(datos.gratificacion)) / 6",
                     valor: datos.sextoGratificacion)
                Fila(titulo: "Remuneración computable", valor: datos.remuneracionComputable, destacado: true)
            }

            Section("Cálculo de la CTS") {
                Fila(titulo: "Por meses", detalle: "RC / 12 × \(datos.meses)", valor: datos.ctsPorMeses)
                Fila(titulo: "Por días", detalle: "RC / 360 × \(datos.dias)", valor: datos.ctsPorDias)
                Fila(titulo: "Descuento por faltas", detalle: "RC / 360 × \(datos.faltas)",
                     valor: datos.descuentoFaltas, color: .red)
                Fila(titulo: "CTS total", valor: datos.ctsTotal, destacado: true, color: .green)
            }

            Section {
                Text("D.S. 001-97-TR (Ley de CTS) · Ley 30334 (gratificación) · Ley 25129 (asignación familiar)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } header: {
                Text("Base legal")
            }
        }
        .navigationTitle("Resultado")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Fila con concepto, explicación opcional y monto
struct Fila: View {
    let titulo: String
    var detalle: String? = nil
    let valor: Double
    var destacado = false
    var color: Color = .primary

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(titulo)
                    .fontWeight(destacado ? .bold : .regular)
                if let detalle {
                    Text(detalle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Text(soles(valor))
                .fontWeight(destacado ? .bold : .regular)
                .foregroundStyle(color)
                .monospacedDigit()
        }
    }
}

#Preview {
    NavigationStack {
        ResultadoView(datos: DatosCTS())
    }
}
