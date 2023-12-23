//
//  DetailsViewController.swift
//  Architectures
//
//  Created by developer on 23.12.2023.
//

import UIKit

protocol DetailsViewInterface: AnyObject {
    func show(title: String, description: String?, icon: UIImage?)
}

class DetailsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = titleText
        descriptionLabel.text = descriptionText ?? ""
        iconView.image = icon
    }

    @IBOutlet private weak var iconView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!

    private var titleText = ""
    private var descriptionText: String?
    private var icon: UIImage?
}

extension DetailsViewController: DetailsViewInterface {
    func show(title: String, description: String?, icon: UIImage?) {
        if nil != titleLabel {
            titleLabel.text = title
            descriptionLabel.text = description ?? ""
            iconView.image = icon
        } else {
            self.titleText = title
            self.descriptionText = description
            self.icon = icon
        }
    }
}
