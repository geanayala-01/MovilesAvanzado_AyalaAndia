//
//  ComprobanteViewController.swift
//  VALOR AGREGADO · Comprobante de venta que se puede compartir como PDF.
//  Lee todo desde la venta y sus relaciones: venta ▸ cliente, venta ▸ producto, venta ▸ vendedor.
//

import UIKit
import CoreData

class ComprobanteViewController: UIViewController {

    let venta: Venta
    let ticket = UIView()

    init(venta: Venta) {
        self.venta = venta
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    // Número correlativo a partir del id interno de Core Data (p7 → V-000007)
    var numero: String {
        let id = venta.objectID.uriRepresentation().lastPathComponent.filter(\.isNumber)
        return "V-" + String(repeating: "0", count: max(0, 6 - id.count)) + id
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Comprobante"
        view.backgroundColor = .systemGroupedBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .action, primaryAction: UIAction { [weak self] _ in
            self?.compartir()
        })
        if presentingViewController != nil && navigationController?.viewControllers.first === self {
            navigationItem.leftBarButtonItem = UIBarButtonItem(systemItem: .close, primaryAction: UIAction { [weak self] _ in
                self?.dismiss(animated: true)
            })
        }
        armarTicket()
    }

    // MARK: - Ticket

    func armarTicket() {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)

        ticket.backgroundColor = .white
        ticket.layer.cornerRadius = 16
        ticket.overrideUserInterfaceStyle = .light   // el ticket siempre blanco, como un papel
        ticket.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(ticket)

        let compartirBtn = Formulario.botonPrincipal("Compartir comprobante (PDF)")
        compartirBtn.addAction(UIAction { [weak self] _ in self?.compartir() }, for: .touchUpInside)
        compartirBtn.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(compartirBtn)

        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.topAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ticket.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 16),
            ticket.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: 20),
            ticket.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -20),
            compartirBtn.topAnchor.constraint(equalTo: ticket.bottomAnchor, constant: 20),
            compartirBtn.leadingAnchor.constraint(equalTo: ticket.leadingAnchor),
            compartirBtn.trailingAnchor.constraint(equalTo: ticket.trailingAnchor),
            compartirBtn.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -24)
        ])

        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 6
        s.translatesAutoresizingMaskIntoConstraints = false
        ticket.addSubview(s)
        NSLayoutConstraint.activate([
            s.topAnchor.constraint(equalTo: ticket.topAnchor, constant: 20),
            s.bottomAnchor.constraint(equalTo: ticket.bottomAnchor, constant: -20),
            s.leadingAnchor.constraint(equalTo: ticket.leadingAnchor, constant: 20),
            s.trailingAnchor.constraint(equalTo: ticket.trailingAnchor, constant: -20)
        ])

        // Encabezado de la tienda
        let icono = UIImageView(image: UIImage(systemName: "cart.fill"))
        icono.tintColor = .systemBlue
        icono.contentMode = .scaleAspectFit
        icono.heightAnchor.constraint(equalToConstant: 34).isActive = true
        s.addArrangedSubview(icono)
        s.addArrangedSubview(texto("Ventas Tecsup", 20, .bold, .center))
        s.addArrangedSubview(texto("Comprobante de venta \(numero)", 14, .regular, .center, .darkGray))
        s.addArrangedSubview(separador())

        // Datos generales (salen de las relaciones)
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy HH:mm"
        let cliente = venta.cliente
        let categoria = cliente.map { Reglas.categoria($0).rawValue } ?? "—"
        s.addArrangedSubview(fila("Fecha", venta.fecha.map { df.string(from: $0) } ?? "—"))
        s.addArrangedSubview(fila("Vendedor", venta.vendedor?.nombre ?? "—"))
        s.addArrangedSubview(fila("Cliente", cliente?.nombre ?? "—"))
        s.addArrangedSubview(fila("Documento", cliente?.documento ?? "—"))
        s.addArrangedSubview(fila("Categoría actual", categoria))
        s.addArrangedSubview(separador())

        // Detalle del producto
        s.addArrangedSubview(texto("\(venta.producto?.nombre ?? "—")", 15, .semibold))
        s.addArrangedSubview(fila("\(venta.cantidad) × \(venta.precioUnitario.soles)", subtotal.soles))
        s.addArrangedSubview(separador())

        // Totales
        s.addArrangedSubview(fila("Subtotal", subtotal.soles))
        s.addArrangedSubview(fila(venta.descuento > 0 ? "Descuento VIP 10%" : "Descuento", "− " + venta.descuento.soles))
        s.addArrangedSubview(fila("IGV 18%", venta.igv.soles))
        s.addArrangedSubview(fila("TOTAL", venta.total.soles, negrita: true))

        // Sello de anulada con su motivo
        if venta.anulada {
            s.addArrangedSubview(separador())
            let sello = texto("ANULADA", 22, .heavy, .center, .systemRed)
            sello.layer.borderColor = UIColor.systemRed.cgColor
            sello.layer.borderWidth = 2
            sello.layer.cornerRadius = 8
            sello.heightAnchor.constraint(equalToConstant: 40).isActive = true
            s.addArrangedSubview(sello)
            s.addArrangedSubview(texto("Motivo: \(venta.motivoAnulacion ?? "—")", 13, .regular, .center, .systemRed))
        }

        s.addArrangedSubview(separador())
        s.addArrangedSubview(texto("¡Gracias por su compra!", 13, .regular, .center, .darkGray))
    }

    var subtotal: Double { Reglas.redondear(venta.precioUnitario * Double(venta.cantidad)) }

    func texto(_ t: String, _ tam: CGFloat, _ peso: UIFont.Weight, _ al: NSTextAlignment = .left,
               _ color: UIColor = .black) -> UILabel {
        let l = UILabel()
        l.text = t
        l.font = .systemFont(ofSize: tam, weight: peso)
        l.textAlignment = al
        l.textColor = color
        l.numberOfLines = 0
        return l
    }

    func fila(_ izq: String, _ der: String, negrita: Bool = false) -> UIView {
        let tam: CGFloat = negrita ? 18 : 14
        let a = texto(izq, tam, negrita ? .bold : .regular, .left, negrita ? .black : .darkGray)
        let b = texto(der, tam, negrita ? .bold : .medium, .right)
        b.setContentCompressionResistancePriority(.required, for: .horizontal)
        let f = UIStackView(arrangedSubviews: [a, b])
        f.spacing = 8
        return f
    }

    func separador() -> UIView {
        let l = texto(String(repeating: "- ", count: 40), 10, .regular, .center, .lightGray)
        l.numberOfLines = 1
        l.lineBreakMode = .byClipping
        return l
    }

    // MARK: - Compartir como PDF

    func generarPDF() -> URL? {
        ticket.layoutIfNeeded()
        let tam = ticket.bounds.size
        let margen: CGFloat = 24
        let pagina = CGRect(x: 0, y: 0, width: tam.width + margen * 2, height: tam.height + margen * 2)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("Comprobante-\(numero).pdf")
        let renderer = UIGraphicsPDFRenderer(bounds: pagina)
        do {
            try renderer.writePDF(to: url) { ctx in
                ctx.beginPage()
                UIColor.white.setFill()
                ctx.fill(pagina)
                ctx.cgContext.translateBy(x: margen, y: margen)
                ticket.layer.render(in: ctx.cgContext)
            }
            return url
        } catch {
            print("Error al generar PDF: \(error)")
            return nil
        }
    }

    func compartir() {
        var items: [Any] = ["Comprobante \(numero) · \(venta.cliente?.nombre ?? "") · Total \(venta.total.soles)"]
        if let pdf = generarPDF() { items.append(pdf) }
        let share = UIActivityViewController(activityItems: items, applicationActivities: nil)
        share.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(share, animated: true)
    }
}
