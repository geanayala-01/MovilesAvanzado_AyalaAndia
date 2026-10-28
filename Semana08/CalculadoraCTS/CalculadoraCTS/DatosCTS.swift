import Foundation

// Lógica de la CTS. Cada cálculo es igual a una celda del Excel (Calculadora_CTS.xlsx).
// Base legal: D.S. 001-97-TR (TUO de la Ley de CTS), Ley 30334 y Ley 25129.
struct DatosCTS {

    // MARK: - 1. Datos de entrada (celdas amarillas del Excel)
    // Vienen con el mismo ejemplo del Excel para que ambos den S/ 1,844.36

    var trabajador = "Ana Torres"                          // C7
    var periodo = "Mayo-Octubre"                           // C8
    var sueldo = 3000.0                                    // C9  sueldo al cierre del periodo
    var gratificacion = 3113.0                             // C10 grati SIN la bonificación de 9%
    var tieneHijos = true                                  // C11
    var rmv = 1230.0                                       // C12 RMV vigente (D.S. 015-2026-TR)
    var meses = 6                                          // C13 de 0 a 6
    var dias = 0                                           // C14 de 0 a 29
    var faltas = 2                                         // C15 faltas o licencias sin goce
    var horasExtras: [Double] = [150, 0, 200, 180, 0, 0]   // C17:H17 un monto por mes

    // MARK: - 2. Cálculos intermedios (remuneración computable)

    // C20 = SI(hijos, 10% × RMV, 0)  → Ley 25129
    var asignacionFamiliar: Double {
        tieneHijos ? redondear(0.10 * rmv) : 0
    }

    // C21 = CONTAR.SI(horas extras > 0)
    var mesesConHorasExtras: Int {
        horasExtras.filter { $0 > 0 }.count
    }

    // C22 = las horas extras son regulares si hubo en 3 meses o más
    var horasExtrasRegulares: Bool {
        mesesConHorasExtras >= 3
    }

    // C23 = SI(regulares, SUMA / 6, 0)  → art. 16
    var promedioHorasExtras: Double {
        horasExtrasRegulares ? redondear(horasExtras.reduce(0, +) / 6) : 0
    }

    // C24 = Gratificación / 6
    var sextoGratificacion: Double {
        redondear(gratificacion / 6)
    }

    // C25 = Sueldo + Asig. familiar + Prom. horas extras + 1/6 grati
    var remuneracionComputable: Double {
        redondear(sueldo + asignacionFamiliar + promedioHorasExtras + sextoGratificacion)
    }

    // MARK: - 3. Cálculo de la CTS

    // C28 = RC / 12 × meses
    var ctsPorMeses: Double {
        redondear(remuneracionComputable / 12 * Double(meses))
    }

    // C29 = RC / 360 × días
    var ctsPorDias: Double {
        redondear(remuneracionComputable / 360 * Double(dias))
    }

    // C30 = −(RC / 360 × faltas)
    var descuentoFaltas: Double {
        -redondear(remuneracionComputable / 360 * Double(faltas))
    }

    // C31 = MAX(0, meses + días − faltas)
    var ctsTotal: Double {
        max(0, ctsPorMeses + ctsPorDias + descuentoFaltas)
    }

    // MARK: - Validación (celda C33 del Excel)

    var mensajeError: String? {
        if meses == 6 && dias > 0 {
            return "Con 6 meses los días deben ser 0: el semestre tiene máximo 180 días"
        }
        if faltas > meses * 30 + dias {
            return "Las faltas no pueden ser más que los días trabajados"
        }
        return nil
    }

    // Mayo-Octubre se deposita en noviembre; Noviembre-Abril en mayo
    var mesDeposito: String {
        periodo == "Mayo-Octubre" ? "noviembre" : "mayo"
    }
}

// Igual que REDONDEAR(valor; 2) en Excel
func redondear(_ valor: Double) -> Double {
    (valor * 100).rounded() / 100
}

// Muestra un monto como "S/ 1,844.36"
func soles(_ valor: Double) -> String {
    let texto = abs(valor).formatted(.number.precision(.fractionLength(2)).locale(Locale(identifier: "en_US")))
    return valor < 0 ? "- S/ \(texto)" : "S/ \(texto)"
}
