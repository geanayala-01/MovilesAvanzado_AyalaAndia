# Laboratorio 08 — Calculadora de CTS en SwiftUI

App en SwiftUI que calcula la CTS (Compensación por Tiempo de Servicios) de un trabajador según la ley laboral peruana (D.S. 001-97-TR). Da el mismo resultado que la calculadora en Excel.

**Fórmula:** CTS = (Sueldo + Asig. familiar + Prom. horas extras + 1/6 Gratificación) × (Meses/12 + Días/360 − Faltas/360)

## Proyecto

| Proyecto | Rama | Tema |
|---|---|---|
| `Semana08/CalculadoraCTS` | `main` | Calculadora de CTS con formulario y pantalla de resultado |

## Requerimientos funcionales

| Código | Requerimiento | Implementación |
|---|---|---|
| RF01 | El usuario puede ingresar el nombre del trabajador y elegir el periodo (Mayo-Octubre o Noviembre-Abril) | `FormularioView`: `TextField` + `Picker` |
| RF02 | El usuario puede ingresar el sueldo básico, la gratificación del semestre y la RMV vigente | `CampoSoles` |
| RF03 | El usuario puede indicar si el trabajador tiene hijos para sumar la asignación familiar (10% de la RMV) | `Toggle` + `asignacionFamiliar` |
| RF04 | El usuario puede registrar los meses, días y faltas del semestre sin pasar los límites de ley (6 meses, 29 días, 180 faltas) | `Stepper` |
| RF05 | El usuario puede registrar las horas extras de los 6 meses, que solo se suman si hubo en 3 meses o más | `horasExtras` + `promedioHorasExtras` |
| RF06 | El usuario recibe un aviso y no puede calcular si los datos no son válidos | `mensajeError` + `.disabled` |
| RF07 | El usuario puede calcular la CTS tocando "Calcular CTS" | `NavigationLink` → `ResultadoView` |
| RF08 | El usuario puede ver el total a depositar en soles, el mes de depósito y el detalle de cada cálculo | `ResultadoView` + `DatosCTS` |
| RF09 | El usuario puede volver al formulario para cambiar los datos y calcular otra vez | `NavigationStack` (Back) |

## Ejecutar
1. Abrir `CalculadoraCTS.xcodeproj` en Xcode.
2. Elegir un simulador de iPhone y presionar Run (⌘R).

## Autor
Gean Pierre Ayala Andia
