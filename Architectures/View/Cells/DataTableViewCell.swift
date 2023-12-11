//
//  DataTableViewCell.swift
//  Architectures
//
//  Created by developer on 30.11.2023.
//

import UIKit

class DataTableViewCell: UITableViewCell, DataCellInterface {
    func setup(with item: DetailsItem) {
        iconView.image = item.icon
        titleLabel.text = item.title
        descriptionLabel.text = item.description
    }

    @IBOutlet private weak var iconView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
}
