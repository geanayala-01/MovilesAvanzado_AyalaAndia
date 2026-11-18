# Actividad Semana 11 · Grupo A · Caso Ventas (UIKit + Core Data)

App de una tienda que registra productos, clientes y ventas. Usa un `UITabBarController` cuyas pestañas dependen del rol del usuario (Vendedor o Supervisor). Toda la interfaz está hecha por código (sin storyboard) y los datos se guardan con Core Data.

## Cómo abrirla

1. Abrir `apple_lab11_03_Actividad_Ventas.xcodeproj` en Xcode.
2. Elegir un simulador (por ejemplo iPhone 17 Pro) y presionar ▶ Run.
3. Usuarios de prueba (clave `123456`): `cruiz` y `adiaz` (Vendedor) · `supervisor` (Supervisor). También se puede crear una cuenta nueva.

La primera vez se cargan datos de ejemplo (`DatosIniciales.swift`): 4 productos, 4 clientes y 6 ventas de días anteriores.

## Modelo Core Data (`VentasModel.xcdatamodeld`)

| Entidad | Atributos | Relaciones |
|---|---|---|
| Usuario | nombre, usuario, clave, rol | ventas: To Many ▸ Venta (**Deny**) |
| Producto | nombre, categoria, precio (Double), stock (Int64) | ventas: To Many ▸ Venta (**Deny**) |
| Cliente | nombre, documento | ventas: To Many ▸ Venta (**Deny**) |
| Venta | fecha, cantidad, precioUnitario, descuento, igv, total, anulada (Bool), motivoAnulacion (opcional) | vendedor ▸ Usuario · producto ▸ Producto · cliente ▸ Cliente (To One, Nullify) |

La regla **Deny** hace que Core Data rechace el `save()` si intentas borrar un producto, cliente o usuario que tiene ventas. La app atrapa ese error, hace `rollback()` y muestra una alerta.

## Pantallas

| Pant. | Archivo | Qué hace |
|---|---|---|
| A1 Login | `LoginViewController.swift` | Busca con `usuario ==[c] %@ AND clave == %@`. Si falla, muestra el mensaje genérico "Usuario o clave incorrectos". |
| A2 Registro | `RegistroViewController.swift` | Usuario único sin distinguir mayúsculas, clave de 6 caracteres como mínimo con confirmación, rol. Al registrarse entra directo a la app. |
| A3 Productos | `ProductosViewController.swift` | Búsqueda y chips de categoría (NSCompoundPredicate). Stock en verde (más de 10), ámbar (6 a 10) o rojo (5 o menos). El supervisor puede crear, editar y borrar deslizando. |
| A4 Clientes | `ClientesViewController.swift` | Iniciales, documento, total comprado y categoría calculada. El supervisor puede borrar. |
| A5 Nueva venta | `NuevaVentaViewController.swift` | Vendedor de la sesión, cliente, producto, cantidad con stepper y resumen calculado. Valida el stock y lo descuenta. |
| A6 Mis ventas | `VentasViewControllers.swift` (`MisVentasViewController`) | Usa `vendedor == %@`, indicadores de hoy y del mes, Todas/Hoy/Mes y búsqueda por cliente. Las ventas anuladas salen tachadas. |
| A7 Ventas del equipo | `VentasViewControllers.swift` (`VentasEquipoViewController`) | Chips por vendedor y nombre del vendedor leído de la relación `venta.vendedor`. Se desliza para Anular. |
| A8 Anular | `confirmarAnulacion(_:)` | Alerta con el resumen. El botón Anular está deshabilitado mientras el motivo esté vacío. Al anular se devuelve el stock. |
| A9 Resumen | `ResumenViewController.swift` | Saludo, vendido hoy comparado con ayer, IGV del mes, barras de 7 días, ranking de vendedores y stock bajo (todo con fetch requests). |
| Cuenta | `CuentaViewController.swift` | Nombre, usuario, rol y Cerrar sesión. |

## Valor agregado: comprobante de venta (`ComprobanteViewController.swift`)

- Al tocar cualquier venta en Mis ventas o en Ventas del equipo se abre su comprobante. También aparece con el botón "Ver comprobante" justo después de registrar una venta.
- El comprobante muestra número, fecha, vendedor, cliente, documento, categoría, producto, subtotal, descuento, IGV y total. Todo se lee de las relaciones `venta.cliente`, `venta.producto` y `venta.vendedor`.
- Si la venta está anulada, muestra el sello **ANULADA** con el motivo.
- El botón **Compartir** genera un PDF con `UIGraphicsPDFRenderer` y abre la hoja de compartir del sistema (WhatsApp, correo, Archivos o imprimir).

## Reglas de negocio (`Datos.swift` → `Reglas`)

- **Categoría del cliente** (se calcula, no se guarda): suma de ventas **no anuladas**. Menos de S/ 1,000 es Regular, desde S/ 1,000 es Frecuente y desde S/ 5,000 es VIP.
- **Descuento**: VIP 10 % del subtotal. **IGV**: 18 % de (subtotal − descuento). **Total** = subtotal − descuento + IGV.
- **Stock**: baja al vender. Si la cantidad supera el stock, aparece una alerta y la venta no se registra.
- **Anular**: exige motivo, marca `anulada = true`, devuelve el stock y la venta deja de contar en reportes y en la categoría del cliente.
- **Visibilidad**: el vendedor solo ve sus ventas (`vendedor == %@`) y el supervisor ve todas.

## Casos de prueba

| N.º | Resultado |
|---|---|
| 1 | Registrar `lparedes` (Supervisor) entra a la app. `LPAREDES` se rechaza porque el usuario ya existe. |
| 2 | Si las claves son distintas o tienen 4 caracteres, aparece un mensaje de error. |
| 3 | Con la clave incorrecta aparece "Usuario o clave incorrectos". |
| 4 | 2 Laptop de S/ 200 a Comercial Andina (VIP): 400.00 · −40.00 · IGV 64.80 · total 424.80 · stock 40 → 38 ✔ |
| 5 | 3 Mouse de S/ 35 a Luis Rojas (Regular): 105.00 · IGV 18.90 · total 123.90 |
| 6 | 50 Laptop con stock 40: alerta "Stock insuficiente" y no se registra. |
| 7 | Mis ventas (vendedor) muestra solo sus ventas y no tiene opción de anular. |
| 8 | Anular sin motivo no se puede (botón deshabilitado). Con motivo queda anulada, el stock vuelve a 40 y el resumen baja S/ 424.80 ✔ |
| 9 | Borrar un cliente con ventas: Core Data lo impide (Deny) y se muestra una alerta. |
