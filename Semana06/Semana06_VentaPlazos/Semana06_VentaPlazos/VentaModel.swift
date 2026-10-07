//
//  VentaModel.swift
//  Semana06_VentaPlazos
//
//  Created by Gean Pierre on 7/10/26.
//

import UIKit

// Se usa class y no struct (igual que ClienteModel):
// - hereda de NSObject, y un struct no puede heredar de una clase
// - es un tipo por referencia: la pantalla Resultado recibe la misma
//   instancia que arma Nueva Venta en prepare(for:sender:)
class VentaModel: NSObject {
    var electrodomestico: String = ""
    var subtotal: Double = 0
    var igv: Double = 0
    var base: Double = 0
    var intereses: Double = 0
    var total: Double = 0
    var cuota: Double = 0
//    inicializador sin parametros y con Parametros
    override init()
    {
        self.electrodomestico = ""
        self.subtotal = 0
        self.igv = 0
        self.base = 0
        self.intereses = 0
        self.total = 0
        self.cuota = 0
    }
    init(pElectrodomestico: String, pSubtotal: Double, pIgv: Double, pBase: Double,
         pIntereses: Double, pTotal: Double, pCuota: Double)
    {
        self.electrodomestico = pElectrodomestico
        self.subtotal = pSubtotal
        self.igv = pIgv
        self.base = pBase
        self.intereses = pIntereses
        self.total = pTotal
        self.cuota = pCuota
    }
}
