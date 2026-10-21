import UIKit

class Cultura: NSObject {

    var nombre: String = ""
    var region: String = ""
    var descripcion: String = ""
    var imagen: String = ""

    init(nombre: String, region: String, descripcion: String, imagen: String) {
        self.nombre = nombre
        self.region = region
        self.descripcion = descripcion
        self.imagen = imagen
    }
}
