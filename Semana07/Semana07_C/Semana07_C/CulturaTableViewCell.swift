//
//  CulturaTableViewCell.swift
//  Semana07_C
//

import UIKit

class CulturaTableViewCell: UITableViewCell {

    @IBOutlet weak var culturaImagen: UIImageView!
    @IBOutlet weak var culturaNombre: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
