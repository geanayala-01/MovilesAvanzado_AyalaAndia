import UIKit

class DetalleViewController: UIViewController {

    @IBOutlet weak var imagenCultura: UIImageView!
    @IBOutlet weak var nombreLabel: UILabel!
    @IBOutlet weak var regionLabel: UILabel!
    @IBOutlet weak var descripcionLabel: UILabel!

    //    cultura que llega desde la lista
    var cultura: Cultura?

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let cultura = cultura else { return }
        title = cultura.nombre
        imagenCultura.image = UIImage(named: cultura.imagen)
        nombreLabel.text = cultura.nombre
        regionLabel.text = "Región: \(cultura.region)"
        descripcionLabel.text = cultura.descripcion
    }
}
