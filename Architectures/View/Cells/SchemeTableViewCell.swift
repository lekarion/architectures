//
//  SchemeTableViewCell.swift
//  Architectures
//
//  Created by developer on 01.12.2023.
//

import UIKit

class SchemeTableViewCell: UITableViewCell, SchemeCellInterface {
    func setup(with item: SchemeItem) {
        schemeView.image = item.schemeImage ?? UIImage(systemName: "sun.dust.fill")
    }

    @IBOutlet private weak var schemeView: UIImageView!
}
