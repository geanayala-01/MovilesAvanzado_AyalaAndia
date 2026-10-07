//
//  ViewControllerNuevaVenta.swift
//  Semana06_VentaPlazos
//
//  Created by Gean Pierre on 7/10/26.
//

import UIKit

class ViewControllerNuevaVenta: UIViewController {

//    definir los controles
    @IBOutlet weak var tfElectrodomestico: UITextField!
    @IBOutlet weak var tfPrecioUnitario: UITextField!
    @IBOutlet weak var tfCantidad: UITextField!
    @IBOutlet weak var tfMeses: UITextField!
    @IBOutlet weak var tfInteresMensual: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

//    calculo de la venta a plazos con las formulas del enunciado
    func calcularVenta() -> VentaModel {
        let precioUnitario = Double(self.tfPrecioUnitario.text!) ?? 0
        let cantidad = Double(self.tfCantidad.text!) ?? 0
        let meses = Double(self.tfMeses.text!) ?? 0
        let tasaInteresMensual = Double(self.tfInteresMensual.text!) ?? 0

        let subtotal = precioUnitario * cantidad
        let igv = subtotal * 0.18
        let base = subtotal + igv
        let intereses = base * (tasaInteresMensual / 100) * meses
        let total = base + intereses
        // si no hay meses no se divide entre cero
        let cuota = meses > 0 ? total / meses : 0

        return VentaModel(pElectrodomestico: self.tfElectrodomestico.text!, pSubtotal: subtotal,
                          pIgv: igv, pBase: base, pIntereses: intereses, pTotal: total, pCuota: cuota)
    }

//    se ejecuta antes del segue Show "showResultado" del boton Calcular
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showResultado" {
            let oPantallaResultado = segue.destination as! ViewControllerResultado
            oPantallaResultado.pVenta = calcularVenta()
        }
    }
}
