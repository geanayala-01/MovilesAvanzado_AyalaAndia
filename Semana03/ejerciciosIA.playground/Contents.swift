// Desarrollado por: [TU NOMBRE]
import Foundation // Importa Foundation para funciones básicas

var nombresProd: [String] = [] // Array paralelo con los nombres de los productos
var preciosProd: [Double] = [] // Array paralelo con los precios de los productos
var stocksProd: [Int] = [] // Array paralelo con el stock de cada producto

print("¿Cuántos productos va a registrar?") // Pregunta cuántos productos se cargarán al inicio
let totalProd = Int(readLine() ?? "") ?? 0 // Lee la cantidad de productos, si falla usa 0

for i in 1...totalProd { // Repite una vez por cada producto a registrar
    print("\nProducto \(i) - Nombre:") // Pide el nombre del producto
    nombresProd.append(readLine() ?? "") // Agrega el nombre leído al array de nombres
    print("Precio:") // Pide el precio
    preciosProd.append(Double(readLine() ?? "") ?? 0) // Convierte y agrega el precio al array
    print("Stock:") // Pide el stock
    stocksProd.append(Int(readLine() ?? "") ?? 0) // Convierte y agrega el stock al array
}

var continuar = true // Bandera que controla si el menú se sigue mostrando
while continuar { // Bucle principal del menú, se repite mientras continuar sea true
    print("\n===== MENÚ INVENTARIO =====") // Encabezado del menú
    print("1) Ver inventario") // Opción 1
    print("2) Buscar producto") // Opción 2
    print("3) Ver stock bajo") // Opción 3
    print("4) Valor total") // Opción 4
    print("5) Salir") // Opción 5
    print("Elige una opción:") // Pide al usuario que elija
    let opcion = readLine() ?? "" // Lee la opción elegida como texto

    switch opcion { // Evalúa qué opción escribió el usuario
    case "1": // Caso: ver inventario completo
        print("\n===== INVENTARIO =====") // Encabezado del listado
        for i in 0..<nombresProd.count { // Recorre todos los productos por índice
            print("\(nombresProd[i]) - S/. \(preciosProd[i]) - Stock: \(stocksProd[i])") // Muestra cada producto
        }
    case "2": // Caso: buscar un producto puntual
        print("Nombre a buscar:") // Pide el nombre a buscar
        let buscar = readLine() ?? "" // Lee el nombre buscado
        if let index = nombresProd.firstIndex(of: buscar) { // Busca el índice del nombre en el array
            print("\(buscar): S/. \(preciosProd[index]) - Stock: \(stocksProd[index])") // Muestra el producto encontrado
        } else {
            print("Producto no encontrado") // Mensaje si no existe
        }
    case "3": // Caso: mostrar productos con stock bajo
        print("\n===== STOCK BAJO (< 5) =====") // Encabezado
        for i in 0..<nombresProd.count { // Recorre todos los productos
            if stocksProd[i] < 5 { // Verifica si el stock es menor a 5
                print("\(nombresProd[i]): \(stocksProd[i]) unidades") // Muestra el producto con stock bajo
            }
        }
    case "4": // Caso: calcular el valor total del inventario
        var valorTotal = 0.0 // Acumulador del valor total
        for i in 0..<nombresProd.count { // Recorre todos los productos
            valorTotal += preciosProd[i] * Double(stocksProd[i]) // Suma precio × stock de cada producto
        }
        print("Valor total del inventario: S/. \(valorTotal)") // Muestra el valor total calculado
    case "5": // Caso: salir del programa
        print("Saliendo del sistema...") // Mensaje de despedida
        continuar = false // Cambia la bandera a false para terminar el while
    default: // Caso: cualquier otra opción no válida
        print("Opción no válida") // Mensaje de error
    }
}
