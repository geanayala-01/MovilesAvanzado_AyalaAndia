import Foundation

print("Ingrese el nombre del producto:")
let producto: String = readLine() ?? "Producto General"

print("Ingrese el precio unitario:")
let precioUnitario: Double = Double(readLine() ?? "") ?? 0.0

print("Ingrese la cantidad:")
let cantidad: Int = Int(readLine() ?? "") ?? 0

// Cálculo del monto total de la compra
let montoCompra: Double = precioUnitario * Double(cantidad)

print(" RESUMEN INICIAL ")
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

print(" DETALLE DEL PLAN DE PAGO ")
print("Producto: \(producto)")
print("Monto Compra: S/ \(montoCompra)")
print("Interés (\(Int(porcentajeInteres * 100))%): S/ \(montoInteres)")
print("Monto Final: S/ \(montoFinal)")
print("Cuotas: \(mesesPlan) meses")
print("Cuota Mensual: S/ \(String(format: "%.2f", cuotaMensual))")


print("MES  | MONTO INICIAL  | MONTO MENSUAL  | RESTA POR PAGAR")

var saldoPendiente: Double = montoFinal

for mes in 1...mesesPlan {
    let montoInicialMes: Double = saldoPendiente
    saldoPendiente -= cuotaMensual
    
    if saldoPendiente < 0.01 { saldoPendiente = 0.0 }
    
    let strMes = String(format: "%2d", mes)
    let strInicial = String(format: "%12.2f", montoInicialMes)
    let strMensual = String(format: "%13.2f", cuotaMensual)
    let strResta = String(format: "%15.2f", saldoPendiente)
    
    print(" \(strMes)  |  S/ \(strInicial) |   S/ \(strMensual) |    S/ \(strResta)")
}
print("-------------------------------------------------------------")

