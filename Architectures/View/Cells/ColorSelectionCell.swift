//
//  ColorSelectionCell.swift
//  Architectures
//
//  Created by developer on 26.12.2023.
//

import UIKit

protocol ColorSelectionCellInterface: ActionActivationCellInterface {
    var color: UIColor? { get set }
    var delegate: ColorSelectionCellDelegate? { get set }
}

protocol ColorSelectionCellDelegate: AnyObject {
    func colorSelectionCell(_ cell: ColorSelectionCellInterface, didChange color: UIColor?)
}

class ColorSelectionCell: UITableViewCell {
    weak var delegate: ColorSelectionCellDelegate?

    @IBAction func colorChanged(_ sender: Any) {
        delegate?.colorSelectionCell(self, didChange: colorWell.selectedColor)
    }

    @IBOutlet private weak var colorWell: UIColorWell!
}

extension ColorSelectionCell: ColorSelectionCellInterface {
    var color: UIColor? {
        get { colorWell.selectedColor }
        set { colorWell.selectedColor = newValue }
    }

    func activateAction(presenter: UIViewController?) {
        guard let controller = presenter else { return }

        let picker = UIColorPickerViewController()
        picker.selectedColor = colorWell.selectedColor ?? UIColor.clear
        picker.supportsAlpha = colorWell.supportsAlpha
        picker.delegate = self

        picker.modalPresentationStyle = .popover
        controller.present(picker, animated: true)
    }
}

extension ColorSelectionCell: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        colorWell.selectedColor = viewController.selectedColor
        delegate?.colorSelectionCell(self, didChange: viewController.selectedColor)
    }
}
