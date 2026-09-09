// Metro de Lima y Callao - Consulta en consola

// Datos de las lineas
let lineas: [String: [String]] = [

    "Linea 1": [
        "Bayovar",
        "Santa Rosa",
        "San Martin",
        "San Carlos",
        "Los Postes",
        "Los Jardines",
        "Piramide del Sol",
        "Caja de Agua",
        "Presbitero Maestro",
        "El Angel",
        "Mercado Santa Anita",
        "Jorge Chavez",
        "Atocongo",
        "San Juan",
        "Maria Auxiliadora",
        "Villa Maria",
        "Pumacahua",
        "Parque Industrial",
        "Villa El Salvador"
    ],

    "Linea 2": [
        "Puerto del Callao",
        "Peru",
        "Oscar R. Benavides",
        "El Olivar",
        "Quilca",
        "Morales Duarez",
        "Carmen de la Legua",
        "Insurgentes",
        "Precursores",
        "Faucett",
        "Venezuela",
        "Universitaria",
        "PUCP",
        "Sucre",
        "Brasil",
        "G. Escobedo",
        "Gamarra",
        "N. Arriola",
        "28 de Julio",
        "N. Ayllon",
        "San Juan de Dios",
        "Circunvalacion",
        "Evitamiento",
        "Colectora Industrial",
        "Los Ingenieros",
        "Mercado Santa Anita",
        "Vista Alegre",
        "Prolongacion Javier Prado",
        "Municipalidad de Ate"
    ],

    "Linea 3": [
        "Chimpu Ocllo",
        "San Felipe",
        "Los Incas",
        "Sinchi Roca",
        "Victor Andres Belaunde",
        "Santa Luzmila",
        "Las Palmas",
        "Previ",
        "Los Olivos",
        "Santiago Antunez de Mayolo",
        "Angelica Gamarra",
        "Plaza Lima Norte",
        "Habich",
        "Tomas Valle",
        "San German",
        "Jose Granda",
        "Tingo Maria",
        "La Alborada",
        "Caqueta",
        "Manco Capac",
        "Cabitos",
        "Angamos",
        "Surquillo",
        "Santiago de Surco"
    ],

    "Linea 4": [
        "Nestor Gambetta",
        "Canta Callao",
        "Bocanegra",
        "Aeropuerto",
        "Callao",
        "Estadio Monumental",
        "Ingenieros",
        "La Molina",
        "Los Frutales",
        "Ovalo Monitor Huascar",
        "Ate Vitarte"
    ],

    "Linea 5": [
        "Alejandro Iglesias",
        "Condores",
        "Matellini",
        "Via Expresa",
        "Saenz Peña",
        "Benavides",
        "Republica de Panama",
        "Conchan"
    ],

    "Linea 6": [
        "Naranjal",
        "Los Alisos",
        "Carlos Izaguirre",
        "Megaplaza Norte",
        "UPC",
        "La Encalada",
        "Universitaria",
        "Panamericana Sur",
        "Velasco Astete",
        "Caminos del Inca",
        "Angamos",
        "Surco"
    ]
]

// FUNCIONES

func mostrarLineas() {
    print("\nLineas disponibles:")
    for linea in lineas.keys.sorted() {
        print("- \(linea)")
    }
}

func consultarLinea() {
    print("\nIngrese el nombre de la linea (ejemplo: Linea 1):")

    if let nombreLinea = readLine() {

        if let estaciones = lineas[nombreLinea] {
            print("\nEstaciones de \(nombreLinea):")

            for (indice, estacion) in estaciones.enumerated() {
                print("\(indice + 1). \(estacion)")
            }

        } else {
            print("La linea no existe. Revisa el nombre e intenta de nuevo.")
        }
    }
}

func consultarEstacion() {
    print("\nIngrese el nombre de la estacion (ejemplo: Angamos):")

    if let nombreEstacion = readLine() {

        var lineasEncontradas: [String] = []

        for (linea, estaciones) in lineas {

            for estacion in estaciones {
                if estacion.lowercased() == nombreEstacion.lowercased() {
                    lineasEncontradas.append(linea)
                }
            }
        }

        if lineasEncontradas.isEmpty {
            print("La estacion no fue encontrada. Revisa el nombre e intenta de nuevo.")

        } else {
            print("\nEstacion: \(nombreEstacion)")
            print("Pertenece a:")

            for linea in lineasEncontradas.sorted() {
                print("- \(linea)")
            }

            if lineasEncontradas.count > 1 {
                print("Es una estacion de conexion (se puede cambiar de linea aqui).")
            } else {
                print("Es una estacion regular (solo una linea).")
            }
        }
    }
}

// MENU PRINCIPAL

var continuar = true

while continuar {

    print("\n========================================")
    print("       METRO DE LIMA Y CALLAO")
    print("========================================")
    print("1. Ver todas las lineas")
    print("2. Ver estaciones de una linea")
    print("3. Buscar una estacion")
    print("4. Salir")
    print("Elige una opcion (1-4):")

    if let opcion = readLine() {

        switch opcion {

        case "1":
            mostrarLineas()

        case "2":
            consultarLinea()

        case "3":
            consultarEstacion()

        case "4":
            continuar = false
            print("\nHasta luego.")

        default:
            print("\nOpcion no valida. Elige un numero del 1 al 4.")
        }

    } else {
        print("No se pudo leer la entrada. Intenta de nuevo.")
    }
}
