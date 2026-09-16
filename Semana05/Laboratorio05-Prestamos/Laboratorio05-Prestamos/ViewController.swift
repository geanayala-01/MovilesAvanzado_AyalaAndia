//
//  ViewController.swift
//  Laboratorio05-Prestamos
//
//  Created by Gean Pierre on 16/09/26.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var capitalTextField: UITextField!
    @IBOutlet weak var rateTextField: UITextField!
    @IBOutlet weak var yearsTextField: UITextField!
    @IBOutlet weak var resultLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        resultLabel.text = "Ingresa los datos del préstamo"
    }

    @IBAction func CalcularPrestamo(_ sender: Any) {
        // Obtener los valores de capital, tasa de interés anual y plazo en años
        let capital = Double(capitalTextField.text ?? "") ?? 0
        let annualRate = Double(rateTextField.text ?? "") ?? 0
        let years = Double(yearsTextField.text ?? "") ?? 0

        // Verificar si los valores de entrada son válidos
        if capital == 0 || annualRate == 0 || years == 0 {
            resultLabel.text = "Por favor, ingresa valores válidos."
            return
        }

        // Calcular la tasa de interés mensual en decimal
        let monthlyRate = (annualRate / 100) / 12

        // Calcular el número total de pagos (meses)
        let numberOfPayments = years * 12

        // Calcular la cuota mensual usando la fórmula de amortización
        // M = P x [r(1+r)^n] / [(1+r)^n - 1]
        let factor = pow(1 + monthlyRate, numberOfPayments)
        let monthlyPayment = capital * (monthlyRate * factor) / (factor - 1)

        // Calcular el monto total a pagar (cuota mensual x número de pagos)
        let totalAmount = monthlyPayment * numberOfPayments

        // Mostrar el resultado con 2 decimales
        resultLabel.text = "Cuota mensual: S/ \(String(format: "%.2f", monthlyPayment))\nMonto total a pagar: S/ \(String(format: "%.2f", totalAmount))"
    }

}
