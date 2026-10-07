# Laboratorio 06 — ViewControllers, Navegación, Modales y Segues

Apps en UIKit con Storyboard para aprender a navegar entre pantallas (Navigation Controller y segue Show), abrir ventanas modales y pasar datos entre pantallas con un modelo propio.

## Proyectos

| Proyecto | Rama | Tema |
|---|---|---|
| `Semana06/Semana06` | `main` | Navigation Controller y segue Show |
| `Semana06/Semana06_02` | `main` | Ventanas modales y paso de datos con `ClienteModel` |
| `Semana06/Semana06_VentaPlazos` | `ai-assisted` | Calculadora de venta a plazos con `VentaModel` (IA) |

## Requerimientos funcionales

### Semana06 — Navegación entre pantallas

| Código | Requerimiento | Implementación |
|---|---|---|
| RF01 | El usuario puede reconocer y abrir la app desde el icono de Tecsup en su pantalla de inicio | `AppIcon.appiconset` |
| RF02 | El usuario puede ir de la Pantalla 1 a la Pantalla 2 tocando "A Pantalla 2" | Bar Button Item + segue Show |
| RF03 | El usuario puede regresar a la Pantalla 1 con el botón Back | Navigation Controller |

### Semana06_02 — Registro de cliente con ventana modal

| Código | Requerimiento | Implementación |
|---|---|---|
| RF04 | El usuario puede registrar los apellidos, nombres y DNI de un cliente | `ViewController` + `ClienteModel` |
| RF05 | El usuario puede revisar los datos que ingresó en una ventana de confirmación al tocar "Continuar" | `instantiateViewController` + `present` |
| RF06 | El usuario puede cerrar la confirmación con "Volver" y regresar al formulario para corregir sus datos | `dismiss` |

### Semana06_VentaPlazos — Calculadora de venta a plazos (rama `ai-assisted`)

| Código | Requerimiento | Implementación |
|---|---|---|
| RF07 | El usuario puede registrar una venta a plazos con el electrodoméstico, precio unitario, cantidad, meses e interés mensual | `ViewControllerNuevaVenta` |
| RF08 | El usuario puede calcular el subtotal, IGV, base, intereses, total y cuota mensual de la venta | `calcularVenta()` + `VentaModel` |
| RF09 | El usuario puede ver el resultado de la venta en soles con dos decimales | `ViewControllerResultado` + `String(format:)` |
| RF10 | El usuario puede volver a "Nueva Venta" para cambiar los datos y calcular otra vez | Navigation Controller (Back) |

## Respuestas del laboratorio

### 16. ¿Qué cambio pudo notar en el diseño de la vista 1?
Al hacer *Editor → Embed In → Navigation Controller*:
- La vista 1 ahora tiene una **barra de navegación** arriba (con el texto "Title"), donde luego se pone el botón "A Pantalla 2".
- La **flecha de inicio** (initial view controller) ya no apunta a la vista 1, sino al Navigation Controller.
- Aparece una conexión **root view controller** del Navigation Controller hacia la vista 1: la vista 1 pasa a ser la primera pantalla de la pila de navegación.

### 17. ¿Para qué sirve un Navigation Controller?
Es un contenedor (`UINavigationController`) que maneja una **pila** de pantallas para navegar de forma jerárquica:
- Cuando se abre una pantalla con Show, se **apila** encima de la actual (push).
- Al tocar **Back** (que crea solo) se **desapila** (pop) y se vuelve a la anterior.
- Pone una **barra de navegación** con el título de cada pantalla y sus botones.

Se usa cuando el usuario va de lo general a lo detallado, como en Ajustes del iPhone: Ajustes → General → Información.

### 29. ¿Para qué sirven Show, Show Detail, Present Modally y Present As Popover?

| Segue | Para qué sirve |
|---|---|
| **Show** | Abre la pantalla dentro del Navigation Controller (push): entra desde la derecha y tiene botón Back. Si no hay Navigation Controller, se abre como modal. |
| **Show Detail** | Pensado para `UISplitViewController` (iPad, pantalla dividida): reemplaza el panel de detalle de la derecha. En iPhone se comporta como Show o como modal. |
| **Present Modally** | Abre la pantalla **encima** de la actual, como una tarea aparte (desde iOS 13 sale como una hoja que sube desde abajo). Se cierra con `dismiss`, como el "Volver" de `Semana06_02`. |
| **Present As Popover** | En iPad muestra la pantalla en un **globo** flotante que apunta al botón que lo abrió. En iPhone se adapta y se muestra como modal. |

## Ejecutar
1. Abrir el `.xcodeproj` de cada proyecto en Xcode.
2. Elegir un simulador de iPhone (deployment target iOS 26.0) y presionar Run (⌘R).
3. La calculadora `Semana06_VentaPlazos` está en la rama `ai-assisted`, junto con su `PROMPTS.md`.

## Autor
Gean Pierre Ayala Andia
