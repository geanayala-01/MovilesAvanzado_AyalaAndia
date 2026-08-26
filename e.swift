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

print("\n PLAN DE PAGOS")
print("Seleccione plan de cuotas (6, 12 o 24 meses):")
let mesesPlan: Int = Int(readLine() ?? "") ?? 6

var porcentajeInteres: Double = 0.0

switch mesesPlan {
case 6:
    porcentajeInteres = 0.20 // 20%
case 12:
    porcentajeInteres = 0.40 // 40%
case 24:
    porcentajeInteres = 0.60 // 60%
default:
    print("Plan no válido. Se asignará 6 meses por defecto.")
    porcentajeInteres = 0.20
}

// Cálculos de Interés, Monto Final y Cuota Mensual
let montoInteres: Double = montoCompra * porcentajeInteres
let montoFinal: Double = montoCompra + montoInteres
let cuotaMensual: Double = montoFinal / Double(mesesPlan)

