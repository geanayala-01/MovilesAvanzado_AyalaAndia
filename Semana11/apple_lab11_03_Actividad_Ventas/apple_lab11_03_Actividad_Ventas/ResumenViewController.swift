//
//  ResumenViewController.swift
//  A9 · Panel del supervisor (Reto): indicadores, gráfico 7 días, ranking y stock bajo.
//  Todo se calcula con fetch requests sobre ventas NO anuladas.
//

import UIKit
import CoreData

class ResumenViewController: UIViewController {

    let scroll = UIScrollView()
    let stack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        stack.axis = .vertical
        stack.spacing = 14
        scroll.translatesAutoresizingMaskIntoConstraints = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        scroll.addSubview(stack)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.topAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 12),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -20),
            stack.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -16)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        construir()
    }

    // MARK: - Consultas (fetch requests)

    let cal = Calendar.current

    func ventas(desde: Date, hasta: Date) -> [Venta] {
        Datos.buscar(Venta.self, predicate: NSPredicate(format: "anulada == NO AND fecha >= %@ AND fecha < %@",
                                                         desde as NSDate, hasta as NSDate))
    }

    func totalDia(_ dia: Date) -> Double {
        let inicio = cal.startOfDay(for: dia)
        return ventas(desde: inicio, hasta: cal.date(byAdding: .day, value: 1, to: inicio)!).reduce(0) { $0 + $1.total }
    }

    // MARK: - Interfaz

    func construir() {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let hoy = Date()

        // ① Saludo con nombre y rol
        let fecha = UILabel()
        let df = DateFormatter()
        df.locale = Locale(identifier: "es_PE")
        df.dateFormat = "EEEE d 'de' MMMM"
        let textoFecha = df.string(from: hoy)
        fecha.text = textoFecha.prefix(1).uppercased() + textoFecha.dropFirst()
        fecha.textColor = .secondaryLabel
        fecha.font = .systemFont(ofSize: 13)
        let saludo = UILabel()
        saludo.text = "Hola, \(Sesion.usuario?.nombre.map { $0.split(separator: " ").first.map(String.init) ?? $0 } ?? "")"
        saludo.font = .systemFont(ofSize: 28, weight: .bold)
        let rol = PillLabel()
        rol.mostrar(Sesion.usuario?.rol ?? "", .systemPurple)
        let filaSaludo = UIStackView(arrangedSubviews: [saludo, UIView(), rol])
        filaSaludo.alignment = .center
        stack.addArrangedSubview(fecha)
        stack.addArrangedSubview(filaSaludo)

        // ② Indicadores: vendido hoy vs ayer · IGV del mes
        let vHoy = totalDia(hoy)
        let vAyer = totalDia(cal.date(byAdding: .day, value: -1, to: hoy)!)
        let indHoy = IndicadorView("Vendido hoy")
        indHoy.valor.text = vHoy.soles
        if vAyer > 0 {
            let pct = (vHoy - vAyer) / vAyer * 100
            indHoy.detalle.text = String(format: "%@ %.0f%% vs ayer", pct >= 0 ? "▲" : "▼", abs(pct))
            indHoy.detalle.textColor = pct >= 0 ? .systemGreen : .systemRed
        } else {
            indHoy.detalle.text = "Ayer: S/ 0.00"
        }
        let inicioMes = Periodo.mes.rango!
        let delMes = ventas(desde: inicioMes.0, hasta: inicioMes.1)
        let indIGV = IndicadorView("IGV del mes")
        indIGV.valor.text = delMes.reduce(0) { $0 + $1.igv }.soles
        indIGV.detalle.text = "\(delMes.count) ventas · \(delMes.reduce(0) { $0 + $1.total }.soles)"
        let filaInd = UIStackView(arrangedSubviews: [indHoy, indIGV])
        filaInd.spacing = 12
        filaInd.distribution = .fillEqually
        stack.addArrangedSubview(filaInd)

        // ③ Gráfico de barras de los últimos 7 días
        stack.addArrangedSubview(tarjeta("Ventas de los últimos 7 días (S/)", grafico7Dias()))

        // ④ Ranking de vendedores del mes
        stack.addArrangedSubview(tarjeta("Ranking de vendedores (mes)", ranking(delMes)))

        // ⑤ Productos con stock bajo (≤ 5)
        stack.addArrangedSubview(tarjeta("Stock bajo (≤ 5)", stockBajo()))
    }

    func tarjeta(_ titulo: String, _ contenido: UIView) -> UIView {
        let t = UILabel()
        t.text = titulo
        t.font = .systemFont(ofSize: 13)
        t.textColor = .secondaryLabel
        let s = UIStackView(arrangedSubviews: [t, contenido])
        s.axis = .vertical
        s.spacing = 10
        s.translatesAutoresizingMaskIntoConstraints = false
        let card = UIView()
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 14
        card.addSubview(s)
        NSLayoutConstraint.activate([
            s.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            s.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            s.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            s.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12)
        ])
        return card
    }

    func grafico7Dias() -> UIView {
        let dias = (0..<7).reversed().map { cal.date(byAdding: .day, value: -$0, to: Date())! }
        let totales = dias.map { totalDia($0) }
        let maximo = max(totales.max() ?? 0, 1)
        let letras = ["D", "L", "M", "X", "J", "V", "S"]
        let alto: CGFloat = 120

        let barras = UIStackView()
        barras.distribution = .fillEqually
        barras.spacing = 10
        barras.alignment = .bottom
        for (i, total) in totales.enumerated() {
            let barra = UIView()
            barra.backgroundColor = i == 6 ? .systemBlue : .systemBlue.withAlphaComponent(0.3)
            barra.layer.cornerRadius = 4
            barra.translatesAutoresizingMaskIntoConstraints = false
            barra.heightAnchor.constraint(equalToConstant: max(4, alto * CGFloat(total / maximo))).isActive = true
            let monto = UILabel()
            monto.text = total > 0 ? String(format: "%.0f", total) : ""
            monto.font = .systemFont(ofSize: 9)
            monto.textColor = .secondaryLabel
            monto.textAlignment = .center
            monto.adjustsFontSizeToFitWidth = true
            let dia = UILabel()
            dia.text = letras[cal.component(.weekday, from: dias[i]) - 1]
            dia.font = .systemFont(ofSize: 11)
            dia.textColor = .secondaryLabel
            dia.textAlignment = .center
            let col = UIStackView(arrangedSubviews: [monto, barra, dia])
            col.axis = .vertical
            col.spacing = 3
            barras.addArrangedSubview(col)
        }
        barras.heightAnchor.constraint(equalToConstant: alto + 36).isActive = true
        return barras
    }

    func ranking(_ delMes: [Venta]) -> UIView {
        // Agrupa por la relación venta ▸ vendedor
        var porVendedor = [String: Double]()
        for v in delMes { porVendedor[v.vendedor?.nombre ?? "—", default: 0] += v.total }
        let orden = porVendedor.sorted { $0.value > $1.value }
        let maximo = orden.first?.value ?? 1
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 10
        if orden.isEmpty { s.addArrangedSubview(textoVacio("Sin ventas este mes")) }
        for (i, (nombre, total)) in orden.enumerated() {
            let l = UILabel()
            l.text = "\(i + 1). \(nombre) · \(total.soles)"
            l.font = .systemFont(ofSize: 15, weight: i == 0 ? .semibold : .regular)
            let barra = UIProgressView(progressViewStyle: .bar)
            barra.progress = Float(total / maximo)
            barra.layer.cornerRadius = 2
            barra.clipsToBounds = true
            let fila = UIStackView(arrangedSubviews: [l, barra])
            fila.axis = .vertical
            fila.spacing = 4
            s.addArrangedSubview(fila)
        }
        return s
    }

    func stockBajo() -> UIView {
        let productos = Datos.buscar(Producto.self, predicate: NSPredicate(format: "stock <= 5"),
                                     orden: [NSSortDescriptor(key: "stock", ascending: true)])
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 8
        if productos.isEmpty { s.addArrangedSubview(textoVacio("Todo el stock está bien")) }
        for p in productos {
            let l = UILabel()
            l.text = "\(p.nombre ?? "") · \(p.stock) u."
            l.font = .systemFont(ofSize: 15, weight: .semibold)
            let pill = PillLabel()
            pill.mostrar("Reponer", .systemRed)
            let fila = UIStackView(arrangedSubviews: [l, UIView(), pill])
            fila.alignment = .center
            s.addArrangedSubview(fila)
        }
        return s
    }

    func textoVacio(_ t: String) -> UILabel {
        let l = UILabel()
        l.text = t
        l.textColor = .secondaryLabel
        return l
    }
}
