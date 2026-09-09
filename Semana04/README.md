# Metro de Lima y Callao — Consulta en Consola

Sistema en Swift que simula la red del Metro de Lima y Callao (Líneas 1-6) usando diccionarios.

## Requerimientos funcionales

| Código | Requerimiento | Implementación |
|---|---|---|
| RF01 | Almacenar líneas y estaciones en diccionarios | `let lineas: [String: [String]]` |
| RF02 | Consultar estaciones de una línea | `consultarLinea()` |
| RF03 | Consultar una estación y sus conexiones | `consultarEstacion()` |
| RF04 | Validar entradas erróneas | `if let` + `default` del `switch` |
| RF05 | Menú principal en bucle | `while continuar { switch }` |

## Líneas

| Línea | Estaciones | Extremos |
|---|---|---|
| Línea 1 | 19 | Bayóvar ↔ Villa El Salvador |
| Línea 2 | 29 | Puerto del Callao ↔ Municipalidad de Ate |
| Línea 3 | 24 | Chimpu Ocllo ↔ Santiago de Surco |
| Línea 4 | 11 | Néstor Gambetta ↔ Ate Vitarte |
| Línea 5 | 8 | Alejandro Iglesias ↔ Conchán |
| Línea 6 | 12 | Naranjal ↔ Surco |

## Estaciones de conexión

| Estación | Conecta |
|---|---|
| Mercado Santa Anita | Línea 1 ↔ Línea 2 |
| Angamos | Línea 3 ↔ Línea 6 |
| Universitaria | Línea 2 ↔ Línea 6 |

## Ejecutar

## Autor
Gean Ayala
