import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //    lista de Culturas Peruanas
    var listaCulturas = [
        Cultura(nombre: "Caral", region: "Lima (Barranca)", descripcion: "Considerada la civilización más antigua de América (aprox. 3000 a.C.). Construyó la Ciudad Sagrada de Caral con pirámides y plazas circulares.", imagen: "caral"),
        Cultura(nombre: "Chavín", region: "Áncash", descripcion: "Cultura del período Formativo cuyo centro ceremonial fue Chavín de Huántar. Destaca por el Lanzón monolítico y las cabezas clavas.", imagen: "chavin"),
        Cultura(nombre: "Paracas", region: "Ica", descripcion: "Famosa por sus finos mantos textiles y por las trepanaciones craneanas, una avanzada práctica médica.", imagen: "paracas"),
        Cultura(nombre: "Nasca", region: "Ica", descripcion: "Conocida por las Líneas de Nasca, enormes geoglifos en el desierto, y por los acueductos de Cantalloc.", imagen: "nasca"),
        Cultura(nombre: "Mochica", region: "La Libertad y Lambayeque", descripcion: "Destacó por sus huacos retrato, las Huacas del Sol y de la Luna y la tumba del Señor de Sipán.", imagen: "mochica"),
        Cultura(nombre: "Wari", region: "Ayacucho", descripcion: "Considerado el primer imperio andino. Desarrolló centros urbanos planificados y una red de caminos.", imagen: "wari"),
        Cultura(nombre: "Chimú", region: "La Libertad", descripcion: "Construyó Chan Chan, la ciudad de barro más grande de América, y destacó en orfebrería.", imagen: "chimu"),
        Cultura(nombre: "Inca", region: "Cusco", descripcion: "Formó el Tahuantinsuyo, el imperio más grande de América precolombina. Construyó Machu Picchu y el Qhapaq Ñan.", imagen: "inca")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Culturas del Perú"
    }

    //    Métodos del data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listaCulturas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "culturaCell", for: indexPath) as! CulturaTableViewCell
        let cultura = listaCulturas[indexPath.row]
        cell.culturaNombre.text = cultura.nombre
        cell.culturaImagen.image = UIImage(named: cultura.imagen)
        return cell
    }

    //    al seleccionar una cultura, ir a la pantalla de detalle
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "irDetalle", sender: listaCulturas[indexPath.row])
    }

    //    enviar la cultura seleccionada a la vista de detalle
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "irDetalle",
           let destino = segue.destination as? DetalleViewController,
           let cultura = sender as? Cultura {
            destino.cultura = cultura
        }
    }
}
