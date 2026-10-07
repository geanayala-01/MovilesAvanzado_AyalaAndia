# Prompts — Lab 06
## Docente: Juan Leon — Tecsup
## Herramienta: Claude

## Ejercicio 4 — Calculadora de venta a plazos de electrodomésticos
### Prompt (CTRFE):
// CONTEXTO: Estudiante de iOS en la semana 6 del curso de Programación en Móviles Avanzado, aprendiendo ViewControllers, navegación con UINavigationController, segues (Show / Present Modally) y paso de datos entre pantallas con un modelo propio (ClienteModel: NSObject) en UIKit con Storyboard.
// TAREA: Crear una app con dos pantallas. "Nueva Venta" con 5 UITextField (electrodoméstico, precio unitario, cantidad, meses, interés mensual %) y un botón "Calcular". "Resultado" con 6 UILabel (subtotal, IGV, base, intereses, total, cuota mensual). Definir class VentaModel: NSObject con esas 6 salidas en Double, hacer el cálculo en "Nueva Venta" con las fórmulas: subtotal = precioUnitario x cantidad, igv = subtotal x 0.18, base = subtotal + igv, intereses = base x (tasaInteresMensual / 100) x meses, total = base + intereses, cuota = total / meses. Pasar el VentaModel a "Resultado" con un segue Show de identifier showResultado y prepare(for:sender:), y mostrar cada valor con String(format: "S/. %.2f", valor).
// RESTRICCIONES: Solo lo visto hasta semana 6: clases, UINavigationController, prepare(for:sender:), IBOutlet/IBAction. Nada de Combine, Codable ni persistencia. Explicar por qué VentaModel es class y no struct, según lo visto en el PREDICT del Ejercicio 2.
// FORMATO: Código Swift de las 3 clases (VentaModel, ViewControllerNuevaVenta, ViewControllerResultado) con comentarios cortos, más los pasos para armar el Storyboard (controles, outlets, segue y Custom Class).
// EJEMPLO: Basado en el Ejercicio 2 (Semana06_02): ClienteModel: NSObject con init() e init con parámetros, y ViewControllerConfirmacion que recibe pCliente y lo muestra en viewDidLoad.

### Resultado de prueba
Refrigeradora, precio 1750, cantidad 2, 12 meses, 1% mensual:

| Concepto | Valor |
|---|---|
| Subtotal | S/. 3500.00 |
| IGV (18%) | S/. 630.00 |
| Base | S/. 4130.00 |
| Intereses | S/. 495.60 |
| Total | S/. 4625.60 |
| Cuota mensual | S/. 385.47 |

Coincide con el ejemplo del enunciado.

### ¿Por qué VentaModel es class y no struct? (explicación de la IA)
- VentaModel hereda de NSObject, igual que ClienteModel, y un struct no puede heredar de ninguna clase.
- Una class es un tipo por referencia: "Resultado" recibe la misma instancia que armó "Nueva Venta" en prepare(for:sender:).
- Un struct es un tipo por valor: al asignarlo a pVenta se copia. Para pasar datos hacia adelante igual funcionaría, porque "Resultado" solo lee la copia; lo que no funcionaría es que "Resultado" modifique el modelo y "Nueva Venta" vea el cambio.

### Reflexión: ¿qué hizo distinto la IA?
- No validó los campos vacíos con guard let ni mostró alertas: usó `Double(texto) ?? 0`, así que un campo vacío o mal escrito se toma como 0.
- Agregó por su cuenta una protección contra división entre cero: si meses es 0, la cuota sale 0.
- No usó IBAction para el botón Calcular: el segue Show sale directo del botón, y el cálculo se hace dentro de prepare(for:sender:) llamando a una función aparte, `calcularVenta()`.
- Agregó a VentaModel una propiedad `electrodomestico` (además de las 6 salidas) para mostrar el nombre del producto en "Resultado".
- Mantuvo el estilo de clase: `init()` e `init` con parámetros con prefijo `p`, comentarios `//` y `as!` para el destino del segue.
