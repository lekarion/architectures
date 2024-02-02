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
    weak var delegate: ColorSelectionCellDelegate? {
        didSet {
            guard nil != delegate else { return }
            setupIfNeed()
        }
    }

    private func setupIfNeed() {
        guard !setupCompleted else { return }

        colorWell.addAction(UIAction(handler: { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.colorSelectionCell(self, didChange: self.colorWell.selectedColor)
        }), for: .valueChanged)

        setupCompleted = true
    }

    @IBOutlet private weak var colorWell: UIColorWell!

    private var setupCompleted = false
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
