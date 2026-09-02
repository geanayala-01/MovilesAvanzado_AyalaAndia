// Desarrollado por: [TU NOMBRE]
import Foundation // Importa el framework Foundation, necesario para funciones básicas de Swift

var notasAlumnos: [String: [Double]] = [:] // Diccionario que guarda el nombre del alumno y su lista de 3 notas

print("¿Cuántos alumnos?") // Pregunta cuántos alumnos se van a registrar
let cantidadAlumnos = Int(readLine() ?? "") ?? 0 // Lee la cantidad y la convierte a Int, si falla usa 0

for i in 1...cantidadAlumnos { // Repite una vez por cada alumno
    print("\nAlumno \(i) - Nombre:") // Pide el nombre del alumno actual
    let nombre = readLine() ?? "" // Lee el nombre, si falla usa cadena vacía
    var notas: [Double] = [] // Array temporal para guardar las 3 notas de este alumno
    for j in 1...3 { // Repite 3 veces, una por cada nota
        print("Nota \(j) de \(nombre):") // Pide la nota j
        let nota = Double(readLine() ?? "") ?? 0 // Lee y convierte la nota a Double, si falla usa 0
        notas.append(nota) // Agrega la nota al array temporal
    }
    notasAlumnos[nombre] = notas // Guarda el array de 3 notas en el diccionario bajo la clave del nombre
}

print("\n===== REPORTE DE NOTAS =====") // Encabezado del reporte
var promedios: [String: Double] = [:] // Diccionario para guardar el promedio de cada alumno
var sumaGeneral = 0.0 // Acumulador para el promedio general de toda la clase
var aprobadosCount = 0 // Contador de alumnos aprobados

for (nombre, notas) in notasAlumnos { // Recorre cada alumno con su array de notas
    let suma = notas.reduce(0, +) // Suma todas las notas del alumno usando reduce
    let promedio = suma / Double(notas.count) // Calcula el promedio dividiendo entre la cantidad de notas
    promedios[nombre] = promedio // Guarda el promedio calculado en el diccionario de promedios

    var clasificacion = "" // Variable para guardar la clasificación textual
    switch promedio { // Evalúa el promedio para asignar una clasificación
    case 17...20: clasificacion = "Excelente" // Si está entre 17 y 20, es Excelente
    case 14..<17: clasificacion = "Bueno" // Si está entre 14 y 16.99, es Bueno
    case 13..<14: clasificacion = "Aprobado" // Si está entre 13 y 13.99, es Aprobado
    default: clasificacion = "Desaprobado" // Cualquier otro caso (menor a 13), Desaprobado
    }

    print("\(nombre): Promedio=\(promedio) → \(clasificacion)") // Muestra el resultado individual
    sumaGeneral += promedio // Suma el promedio del alumno al acumulador general
    if promedio >= 13 { aprobadosCount += 1 } // Si el promedio es aprobatorio, incrementa el contador
}

let promedioGeneral = sumaGeneral / Double(notasAlumnos.count) // Calcula el promedio general de la clase
print("\nPromedio general: \(promedioGeneral)") // Muestra el promedio general

let notaMasAlta = promedios.values.max() ?? 0 // Obtiene el valor máximo entre todos los promedios
let notaMasBaja = promedios.values.min() ?? 0 // Obtiene el valor mínimo entre todos los promedios
print("Nota más alta: \(notaMasAlta)") // Muestra la nota más alta
print("Nota más baja: \(notaMasBaja)") // Muestra la nota más baja

let porcentajeAprobados = (Double(aprobadosCount) / Double(notasAlumnos.count)) * 100 // Calcula el % de aprobados
print("Porcentaje de aprobados: \(porcentajeAprobados)%") // Muestra el porcentaje de aprobados

let ordenados = promedios.sorted { $0.value > $1.value } // Ordena el diccionario de promedios de mayor a menor
print("\n===== RANKING =====") // Encabezado del ranking
for (nombre, promedio) in ordenados { // Recorre la lista ya ordenada
    print("\(nombre): \(promedio)") // Muestra cada alumno con su promedio en orden
}
