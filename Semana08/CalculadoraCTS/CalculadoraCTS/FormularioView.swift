import SwiftUI

// PANTALLA 1: el usuario escribe los datos (bloque "1. Datos de entrada" del Excel)
struct FormularioView: View {
    @State private var datos = DatosCTS()

    let periodos = ["Mayo-Octubre", "Noviembre-Abril"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Trabajador") {
                    TextField("Nombre", text: $datos.trabajador)
                    Picker("Periodo", selection: $datos.periodo) {
                        ForEach(periodos, id: \.self) { periodo in
                            Text(periodo)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section {
                    CampoSoles(titulo: "Sueldo básico", valor: $datos.sueldo)
                    CampoSoles(titulo: "Gratificación", valor: $datos.gratificacion)
                    Toggle("¿Tiene hijos menores de 18?", isOn: $datos.tieneHijos)
                    CampoSoles(titulo: "RMV vigente", valor: $datos.rmv)
                } header: {
                    Text("Remuneración")
                } footer: {
                    Text("La gratificación va sin la bonificación de 9% (Ley 30334).")
                }

                Section {
                    Stepper("Meses completos: \(datos.meses)", value: $datos.meses, in: 0...6)
                    Stepper("Días adicionales: \(datos.dias)", value: $datos.dias, in: 0...29)
                    Stepper("Faltas: \(datos.faltas)", value: $datos.faltas, in: 0...180)
                } header: {
                    Text("Tiempo trabajado en el semestre")
                } footer: {
                    Text("Vacaciones y licencias con goce no son faltas.")
                }

                Section {
                    ForEach(0..<6) { mes in
                        CampoSoles(titulo: "Mes \(mes + 1)", valor: $datos.horasExtras[mes])
                    }
                } header: {
                    Text("Horas extras del semestre")
                } footer: {
                    Text("Solo cuentan si hubo horas extras en 3 meses o más.")
                }

                // Misma validación que la celda C33 del Excel
                if let error = datos.mensajeError {
                    Section {
                        Label(error, systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                    }
                }
            }
            .navigationTitle("Calculadora CTS")
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom) {
                NavigationLink {
                    ResultadoView(datos: datos)
                } label: {
                    Label("Calcular CTS", systemImage: "equal.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .disabled(datos.mensajeError != nil)
                .padding()
            }
        }
    }
}

// Fila con un título a la izquierda y un monto en soles a la derecha
struct CampoSoles: View {
    let titulo: String
    @Binding var valor: Double

    var body: some View {
        HStack {
            Text(titulo)
            Spacer()
            Text("S/")
                .foregroundStyle(.secondary)
            TextField("0.00", value: $valor, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 100)
        }
    }
}

#Preview {
    FormularioView()
}
