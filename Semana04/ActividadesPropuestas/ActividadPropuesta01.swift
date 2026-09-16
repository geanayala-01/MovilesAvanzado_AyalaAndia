// ===== ACTIVIDAD PROPUESTA 01 — CURSOS LIBRES TECSUP =====
// Alumno: Ayala Andia
// Enunciado: un alumno puede llevar uno o más cursos libres.
// - Si lleva 3 o más cursos: 10% de descuento sobre el total CON IGV (18%).
// - Si además es alumno de Tecsup y lleva 3 o más cursos: descuento adicional de S/ 400.

import Foundation

struct Curso {
    let nombre: String
    let precio: Double
}

class Alumno {
    let nombre: String
    let esAlumnoTecsup: Bool
    var cursos: [Curso] = []

    init(nombre: String, esAlumnoTecsup: Bool) {
        self.nombre = nombre
        self.esAlumnoTecsup = esAlumnoTecsup
    }

    func matricular(curso: Curso) {
        cursos.append(curso)
    }

    func calcularSubtotal() -> Double {
        var subtotal = 0.0
        for curso in cursos {
            subtotal += curso.precio
        }
        return subtotal
    }

    func calcularTotalConIGV() -> Double {
        let subtotal = calcularSubtotal()
        return subtotal * 1.18
    }

    func calcularTotalFinal() -> Double {
        var total = calcularTotalConIGV()
        if cursos.count >= 3 {
            total = total - (total * 0.10)
            if esAlumnoTecsup {
                total = total - 400.0
            }
        }
        return total
    }

    func mostrarResumen() {
        print("🎓 Alumno: \(nombre)")
        print("Es alumno Tecsup: \(esAlumnoTecsup ? "Sí" : "No")")
        print("Cursos matriculados: \(cursos.count)")
        for curso in cursos {
            print(" - \(curso.nombre): S/ \(String(format: "%.2f", curso.precio))")
        }
        print("Subtotal: S/ \(String(format: "%.2f", calcularSubtotal()))")
        print("Total con IGV (18%): S/ \(String(format: "%.2f", calcularTotalConIGV()))")
        print("Total final a pagar: S/ \(String(format: "%.2f", calcularTotalFinal()))")
    }
}
