//
//  DetailsViewController.swift
//  Architectures
//
//  Created by developer on 23.12.2023.
//

import UIKit

protocol DetailsViewInterface: AnyObject {
    var actionDelegate: DetailsViewActionDelegate? { get set }
    func show(item: DetailsItem)
}

protocol DetailsViewActionDelegate: AnyObject {
    func detailsView(_ view: DetailsViewInterface, didRequestDuplicate item: DetailsItem)
}

class DetailsViewController: UIViewController {
    weak var actionDelegate: DetailsViewActionDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = item?.title ?? ""
        descriptionLabel.text = item?.description ?? ""
        iconView.image = item?.icon
    }

    @IBOutlet private weak var iconView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!

    private var item: DetailsItem?
}

extension DetailsViewController: DetailsViewInterface {
    func show(item: DetailsItem) {
        if nil != titleLabel {
            titleLabel.text = item.title
            descriptionLabel.text = item.description ?? ""
            iconView.image = item.icon
        }

        self.item = item
    }
}
