# Actividad Semana 11 · Grupo B · Caso Compras (SwiftUI + SwiftData)

Una distribuidora registra sus proveedores, el costo de sus productos y las compras al contado o al crédito. La app usa un `TabView` cuyas pestañas dependen del rol (Comprador o Supervisor). Los datos se guardan con SwiftData.

## Cómo abrirla

1. Abrir `apple_lab11_04_Actividad_Compras.xcodeproj` en Xcode y presionar ▶ Run.
2. Usuarios de prueba (clave `123456`): `mtorres2` y `rvega` (Comprador) · `supervisor` (Supervisor). También se puede crear una cuenta nueva.
3. En el simulador la app aparece con el ícono verde y el nombre **Compras**.

La primera vez se cargan datos de ejemplo (`DatosIniciales` en `Reglas.swift`):
- 4 productos (Laptop con stock 40 y costo promedio 110.00 para el caso 3).
- 3 proveedores.
- 5 compras, entre ellas una a crédito ya **vencida** (caso 8) y una **rechazada**.

## Modelo SwiftData (`Modelos.swift`)

| Clase @Model | Propiedades | Relaciones |
|---|---|---|
| Usuario | nombre, usuario, clave, rol | compras: [Compra] (`.deny`, inverse) |
| Proveedor | nombre, ruc | compras: [Compra] (`.deny`, inverse) |
| Producto | nombre, categoria, stock (Int), costoPromedio (Double) | compras: [Compra] (`.deny`, inverse) |
| Compra | fecha, cantidad, costoUnitario, igv, total, alCredito, vence, estado (Pendiente/Aprobada/Rechazada), pagada, motivoRechazo? | comprador: Usuario? · proveedor: Proveedor? · producto: Producto? |

## Pantallas

| Pant. | Archivo | Qué hace |
|---|---|---|
| B1 Login | `LoginView.swift` | Login con `#Predicate { $0.usuario == u && $0.clave == c }` y mensaje genérico de error. |
| B2 Registro | `LoginView.swift` (`RegistroView`) | Usuario único (se guarda en minúsculas, con aviso en vivo), clave de mínimo 6 caracteres con confirmación y rol. Entra directo a la app. |
| B3 Productos | `CatalogoViews.swift` | Búsqueda, costo promedio, stock en color y valor del inventario. `.onDelete` solo para el supervisor y bloqueado si el producto tiene compras. |
| B4 Proveedores | `CatalogoViews.swift` | Insignia "Por pagar" o "Al día" y total comprado, calculados desde las compras del proveedor. |
| B5 Nueva compra | `CompraViews.swift` | Proveedor, producto, cantidad, costo, Contado o Crédito 30 días y aviso desde S/ 5,000. El botón dice "Registrar" o "Enviar a aprobación". |
| B6 Mis compras | `CompraViews.swift` | Filtra con `#Predicate` por comprador y estado (Todas, Pendientes, Rechazadas). Las rechazadas muestran su motivo. |
| B7 Aprobar | `SupervisorViews.swift` | Muestra quién solicitó la compra y una vista previa de stock y costo promedio antes y después. Rechazar pide un motivo. |
| B8 Por pagar | `SupervisorViews.swift` | `#Predicate` para Pendientes, Vencidas y Pagadas, con etiqueta VENCIDA. Se desliza para Pagar y muestra el total por pagar. |
| B9 Resumen | `SupervisorViews.swift` | Inventario, crédito fiscal, por pagar, por aprobar (cantidad e importe) y barras por proveedor. |
| Cuenta | `ComprasApp.swift` (`AvatarMenu`) | Menú del avatar con nombre, rol y Cerrar sesión. |

## Valor agregado: orden de compra en PDF (`OrdenCompraView.swift`)

- Al registrar una compra se abre su **orden de compra**. También se abre al tocar cualquier compra en Mis compras o Por pagar.
- La orden muestra número, fecha, comprador, proveedor y RUC, forma de pago, vencimiento, detalle, IGV, total y estado (VENCIDA, Pagada o Por pagar, y el motivo si fue rechazada).
- **Compartir orden (PDF)**: `ImageRenderer` dibuja la vista SwiftUI en un PDF y `ShareLink` abre el menú de compartir.

## Reglas de negocio (`Reglas.swift`)

- **IGV**: 18 % del subtotal. Es crédito fiscal. Total = subtotal + IGV.
- **Aprobación**: si el total es menor a S/ 5,000 la compra queda Aprobada al instante. Desde S/ 5,000 queda **Pendiente** y no cambia nada hasta que el supervisor la apruebe o la rechace con un motivo.
- **Costo promedio ponderado** (al aprobar) = (stock × costoProm + cantidad × costo) / (stock + cantidad).
- **Contado**: la compra queda pagada. **Crédito 30 días**: queda por pagar y vence en 30 días. Si pasa la fecha sin pagarse, se muestra como VENCIDA.
- **Pagar**: solo el supervisor.
- **Visibilidad**: el comprador solo ve sus compras.
- **Borrado**: no se puede borrar un producto, proveedor o usuario que tenga compras (`.deny`).

## Casos de prueba

| N.º | Caso | Resultado |
|---|---|---|
| 1 | Registrar "mtorres" (Comprador) y repetir el usuario | El primero entra; el repetido se rechaza |
| 2 | Login con clave incorrecta | "Usuario o clave incorrectos" |
| 3 | Laptop (stock 40, costo 110) · 10 a 120.00 al crédito | 1,200.00 · IGV 216.00 · total 1,416.00 · Aprobada · stock 50 · costo 112.00 · vence en 30 días ✔ |
| 4 | La misma compra, al contado | Queda pagada y no aparece en Pendientes de pago |
| 5 | Compra de 50 a 120.00 (total 7,080.00) | Queda Pendiente; el stock no cambia ✔ |
| 6 | El supervisor aprueba la compra del caso 5 | Partiendo de stock 40: stock 90 y costo 115.56. Aparece en Por pagar ✔ |
| 7 | Rechazar sin motivo y luego con motivo | Sin motivo no se puede; con motivo queda Rechazada y el comprador ve el motivo |
| 8 | Compra a crédito vencida, luego Pagar | Aparece como VENCIDA; al pagar pasa a Pagadas y baja el total ✔ |
| 9 | El comprador abre Mis compras | Solo ve sus compras y no tiene la opción de Pagar ✔ |
