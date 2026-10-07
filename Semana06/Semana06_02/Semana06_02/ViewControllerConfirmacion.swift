//
//  ViewControllerConfirmacion.swift
//  Semana06_02
//
//  Created by Gean Pierre on 7/10/26.
//

import UIKit

class ViewControllerConfirmacion: UIViewController {
//instanciar la clase ClienteModel
    var pCliente: ClienteModel = ClienteModel()
//    definir los controles
    @IBOutlet weak var tfApellido: UILabel!
    @IBOutlet weak var tfNombre: UILabel!
    @IBOutlet weak var tfDni: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
//        definir los controles
        self.tfApellido.text = pCliente.Apellido
        self.tfNombre.text = pCliente.Nombre
        self.tfDni.text = pCliente.Dni
    }
//    cerrar la ventana modal y regresar a DATOS DEL CLIENTE
    @IBAction func btnVolver(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
