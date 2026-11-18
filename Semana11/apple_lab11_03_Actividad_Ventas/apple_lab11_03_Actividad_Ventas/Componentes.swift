//
//  Componentes.swift
//  Piezas de interfaz reutilizables: chips, avatar, etiqueta, tarjetas y alertas.
//

import UIKit

// MARK: - Alertas rápidas

extension UIViewController {
    func alerta(_ titulo: String, _ mensaje: String) {
        let a = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}

// MARK: - Barra de chips (filtros por categoría / vendedor)

final class ChipsView: UIScrollView {
    private let stack = UIStackView()
    private(set) var seleccionado = 0
    var alCambiar: ((Int) -> Void)?

    init() {
        super.init(frame: .zero)
        showsHorizontalScrollIndicator = false
        stack.axis = .horizontal
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentLayoutGuide.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor, constant: 6),
            stack.bottomAnchor.constraint(equalTo: contentLayoutGuide.bottomAnchor, constant: -6),
            stack.heightAnchor.constraint(equalTo: frameLayoutGuide.heightAnchor, constant: -12),
            heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configurar(_ titulos: [String]) {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if seleccionado >= titulos.count { seleccionado = 0 }
        for (i, t) in titulos.enumerated() {
            let b = UIButton(type: .system)
            b.tag = i
            b.configuration = configuracion(t, activo: i == seleccionado)
            b.addAction(UIAction { [weak self] _ in self?.seleccionar(i) }, for: .touchUpInside)
            stack.addArrangedSubview(b)
        }
    }

    private func configuracion(_ t: String, activo: Bool) -> UIButton.Configuration {
        var c = activo ? UIButton.Configuration.filled() : UIButton.Configuration.gray()
        c.title = t
        c.cornerStyle = .capsule
        c.buttonSize = .small
        return c
    }

    private func seleccionar(_ i: Int) {
        seleccionado = i
        for case let b as UIButton in stack.arrangedSubviews {
            b.configuration = configuracion(b.configuration?.title ?? "", activo: b.tag == i)
        }
        alCambiar?(i)
    }
}

// MARK: - Avatar con iniciales

final class AvatarView: UILabel {
    init(tamano: CGFloat = 40) {
        super.init(frame: .zero)
        textAlignment = .center
        textColor = .white
        font = .boldSystemFont(ofSize: tamano * 0.38)
        layer.cornerRadius = 10
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: tamano).isActive = true
        heightAnchor.constraint(equalToConstant: tamano).isActive = true
    }
    required init?(coder: NSCoder) { fatalError() }

    func mostrar(_ nombre: String, color: UIColor? = nil) {
        text = iniciales(nombre)
        let colores: [UIColor] = [.systemBlue, .systemPurple, .systemTeal, .systemIndigo, .systemOrange, .systemPink]
        backgroundColor = color ?? colores[abs(nombre.hashValue) % colores.count]
    }
}

// MARK: - Etiqueta tipo "pill" (stock, categoría, Anulada)

final class PillLabel: UILabel {
    init() {
        super.init(frame: .zero)
        font = .boldSystemFont(ofSize: 11)
        textColor = .white
        textAlignment = .center
        layer.cornerRadius = 9
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 18).isActive = true
    }
    required init?(coder: NSCoder) { fatalError() }

    override var intrinsicContentSize: CGSize {
        let s = super.intrinsicContentSize
        return CGSize(width: s.width + 14, height: 18)
    }

    func mostrar(_ texto: String, _ color: UIColor) {
        text = texto
        backgroundColor = color
        isHidden = false
    }
}

// MARK: - Celda genérica: avatar · título/subtítulo · monto · etiqueta

final class FilaCell: UITableViewCell {
    static let id = "FilaCell"
    let avatar = AvatarView()
    let titulo = UILabel()
    let subtitulo = UILabel()
    let monto = UILabel()
    let pill = PillLabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        titulo.font = .systemFont(ofSize: 16, weight: .semibold)
        subtitulo.font = .systemFont(ofSize: 13)
        subtitulo.textColor = .secondaryLabel
        monto.font = .systemFont(ofSize: 15, weight: .semibold)
        monto.textAlignment = .right
        monto.setContentCompressionResistancePriority(.required, for: .horizontal)
        pill.setContentCompressionResistancePriority(.required, for: .horizontal)

        let textos = UIStackView(arrangedSubviews: [titulo, subtitulo])
        textos.axis = .vertical
        textos.spacing = 2
        let derecha = UIStackView(arrangedSubviews: [monto, pill])
        derecha.axis = .vertical
        derecha.alignment = .trailing
        derecha.spacing = 4
        let fila = UIStackView(arrangedSubviews: [avatar, textos, derecha])
        fila.spacing = 12
        fila.alignment = .center
        fila.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(fila)
        NSLayoutConstraint.activate([
            fila.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            fila.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            fila.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            fila.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    override func prepareForReuse() {
        super.prepareForReuse()
        pill.isHidden = true
        titulo.attributedText = nil
        monto.attributedText = nil
        titulo.textColor = .label
        monto.textColor = .label
        accessoryType = .none
    }

    // Texto tachado (venta anulada)
    func tachar(_ label: UILabel, _ texto: String) {
        label.attributedText = NSAttributedString(string: texto, attributes: [
            .strikethroughStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: UIColor.secondaryLabel
        ])
    }
}

// MARK: - Tarjeta de indicador (Hoy / Mes / IGV)

final class IndicadorView: UIView {
    let titulo = UILabel()
    let valor = UILabel()
    let detalle = UILabel()

    init(_ t: String) {
        super.init(frame: .zero)
        backgroundColor = .secondarySystemGroupedBackground
        layer.cornerRadius = 14
        titulo.text = t
        titulo.font = .systemFont(ofSize: 12)
        titulo.textColor = .secondaryLabel
        valor.font = .systemFont(ofSize: 22, weight: .bold)
        valor.adjustsFontSizeToFitWidth = true
        detalle.font = .systemFont(ofSize: 12)
        detalle.textColor = .secondaryLabel
        let s = UIStackView(arrangedSubviews: [titulo, valor, detalle])
        s.axis = .vertical
        s.spacing = 2
        s.translatesAutoresizingMaskIntoConstraints = false
        addSubview(s)
        NSLayoutConstraint.activate([
            s.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            s.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            s.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            s.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
}

// Contenedor de cabecera para tablas (se ajusta al alto de su contenido)
func cabecera(_ vistas: [UIView], ancho: CGFloat) -> UIView {
    let s = UIStackView(arrangedSubviews: vistas)
    s.axis = .vertical
    s.spacing = 8
    s.translatesAutoresizingMaskIntoConstraints = false
    let cont = UIView()
    cont.addSubview(s)
    NSLayoutConstraint.activate([
        s.leadingAnchor.constraint(equalTo: cont.leadingAnchor),
        s.trailingAnchor.constraint(equalTo: cont.trailingAnchor),
        s.topAnchor.constraint(equalTo: cont.topAnchor, constant: 4),
        s.bottomAnchor.constraint(equalTo: cont.bottomAnchor, constant: -4)
    ])
    let alto = s.systemLayoutSizeFitting(CGSize(width: ancho, height: 0),
                                         withHorizontalFittingPriority: .required,
                                         verticalFittingPriority: .fittingSizeLevel).height + 8
    cont.frame = CGRect(x: 0, y: 0, width: ancho, height: alto)
    return cont
}

// Envuelve una vista con márgenes laterales
func conMargen(_ v: UIView, _ m: CGFloat = 16) -> UIView {
    let c = UIView()
    v.translatesAutoresizingMaskIntoConstraints = false
    c.addSubview(v)
    NSLayoutConstraint.activate([
        v.leadingAnchor.constraint(equalTo: c.leadingAnchor, constant: m),
        v.trailingAnchor.constraint(equalTo: c.trailingAnchor, constant: -m),
        v.topAnchor.constraint(equalTo: c.topAnchor),
        v.bottomAnchor.constraint(equalTo: c.bottomAnchor)
    ])
    return c
}
