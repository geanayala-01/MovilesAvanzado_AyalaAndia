import Foundation

print("Ingrese el nombre del producto:")
let producto: String = readLine() ?? "Producto General"

print("Ingrese el precio unitario:")
let precioUnitario: Double = Double(readLine() ?? "") ?? 0.0

print("Ingrese la cantidad:")
let cantidad: Int = Int(readLine() ?? "") ?? 0

// Cálculo del monto total de la compra
let montoCompra: Double = precioUnitario * Double(cantidad)

print("\n--- RESUMEN INICIAL ---")
print("Producto: \(producto)")
print("Precio Unitario: S/ \(precioUnitario)")
print("Cantidad: \(cantidad)")
print("Monto Total de la Compra: S/ \(montoCompra)")

