// Desarrollado por: [TU NOMBRE]
import Foundation

// ===== TODO 8: Eliminar duplicados =====
var numeros: [Int] = []
for i in 1...8 {
    print("Número \(i):")
    let n = Int(readLine() ?? "") ?? 0
    numeros.append(n)
}
print("Con duplicados: \(numeros)")
let sinDuplicados = Array(Set(numeros)).sorted()
print("Sin duplicados: \(sinDuplicados)")

// ===== TODO 9: Comparar asistencia =====
var lunes: Set<String> = []
print("===== ASISTENCIA LUNES =====")
for i in 1...4 {
    print("Nombre \(i):")
    lunes.insert(readLine() ?? "")
}

var martes: Set<String> = []
print("===== ASISTENCIA MARTES =====")
for i in 1...4 {
    print("Nombre \(i):")
    martes.insert(readLine() ?? "")
}

let ambosDias = lunes.intersection(martes)
let soloLunes = lunes.subtracting(martes)
let soloMartes = martes.subtracting(lunes)

print("===== RESULTADOS =====")
print("Ambos días: \(ambosDias)")
print("Solo lunes: \(soloLunes)")
print("Solo martes: \(soloMartes)")

let a: Set = [1, 2, 3, 4, 5]
let b: Set = [4, 5, 6, 7, 8]
print(a.intersection(b))      // PREDICT 5: [4, 5] (orden puede variar)
print(a.union(b).count)       // PREDICT 6: 8 (1,2,3,4,5,6,7,8)
print(a.subtracting(b))       // PREDICT 7: [1, 2, 3]

var repetidos: Set = ["A", "B", "A", "C", "B"]
print(repetidos.count)        // PREDICT 8: 3 (Set solo guarda valores únicos: A, B, C)
