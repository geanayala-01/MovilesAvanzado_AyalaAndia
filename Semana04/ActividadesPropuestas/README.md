# Actividades Propuestas — Lab 04 POO en Swift

Dos casos de herencia y polimorfismo en Swift, resueltos con struct/class, sin optionals, sin genéricos y sin closures (mismas restricciones del Lab 04).

## Actividad Propuesta 01 — Cursos libres Tecsup

Un alumno puede matricularse en uno o más cursos libres. Si lleva 3 o más cursos obtiene un descuento del 10% sobre el total con IGV; si además es alumno de Tecsup, se le aplica un descuento adicional de S/ 400 (solo si también lleva 3 o más cursos).

### Requerimientos funcionales

| Código | Requerimiento | Implementación |
|---|---|---|
| RF01 | Registrar los cursos que lleva un alumno | `struct Curso` + `var cursos: [Curso]` en `Alumno` |
| RF02 | Calcular el subtotal de los cursos matriculados | `calcularSubtotal()` |
| RF03 | Calcular el total aplicando IGV (18%) | `calcularTotalConIGV()` |
| RF04 | Aplicar 10% de descuento si el alumno lleva 3 o más cursos | `calcularTotalFinal()` |
| RF05 | Aplicar descuento adicional de S/ 400 a alumnos Tecsup con 3 o más cursos | `calcularTotalFinal()` |
| RF06 | Mostrar el resumen de cada alumno con su total final | `mostrarResumen()` |

**Archivo:** `ActividadPropuesta01.playground`

## Actividad Propuesta 02 — Cliente bancario (herencia y polimorfismo)

Un banco registra dos tipos de cliente: natural y jurídico. Ambos comparten los datos de la cuenta (código, dirección, fecha de registro, número de cuenta y monto mínimo de apertura), pero cada uno agrega sus propios datos particulares.

### Requerimientos funcionales

| Código | Requerimiento | Implementación |
|---|---|---|
| RF01 | Modelar los datos comunes a todo cliente | `class Cliente` con `mostrarDatos()` |
| RF02 | Registrar cliente natural con nombre completo y DNI | `class ClienteNatural: Cliente` |
| RF03 | Registrar cliente jurídico con razón social, RUC y representante legal | `class ClienteJuridico: Cliente` |
| RF04 | Mostrar los datos propios del cliente y luego los datos heredados | `override mostrarDatos()` + `super.mostrarDatos()` |
| RF05 | Recorrer todos los clientes sin importar su tipo, con un solo bucle | `let clientes: [Cliente]` + `for-in` |

**Archivo:** `ActividadPropuesta02.playground`

## Ejecutar

Doble clic en cada `.playground` para abrirlo en Xcode: el resultado aparece en vivo en el panel lateral de cada línea. También se puede correr por consola:

```bash
swift ActividadPropuesta01.playground/Contents.swift
swift ActividadPropuesta02.playground/Contents.swift
```

## Autor
Gean Ayala
