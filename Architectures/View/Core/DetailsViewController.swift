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
    func detailsView(_ view: DetailsViewInterface, isDuplicationAvailableFor item: DetailsItem) -> Bool
    func detailsView(_ view: DetailsViewInterface, didRequestDuplicate item: DetailsItem)
    func detailsViewDidFinish(_ view: DetailsViewInterface)
}

class DetailsViewController: UIViewController {
    weak var actionDelegate: DetailsViewActionDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let item = self.item {
            titleLabel.text = item.title
            descriptionLabel.text = item.description
            iconView.image = item.icon
            duplicateButton.isHidden = !(actionDelegate?.detailsView(self, isDuplicationAvailableFor: item) ?? false)
        } else {
            titleLabel.text = ""
            descriptionLabel.text = ""
            iconView.image = nil
            duplicateButton.isHidden = true
        }
    }

    @IBOutlet private weak var iconView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var duplicateButton: UIButton!

    private var item: DetailsItem?
}

private extension DetailsViewController { // actions
    @IBAction func onOK(_ sender: Any) {
        actionDelegate?.detailsViewDidFinish(self)
    }

    @IBAction func onDuplicate(_ sender: Any) {
        guard let item = self.item else { return }
        actionDelegate?.detailsView(self, didRequestDuplicate: item)
    }
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
