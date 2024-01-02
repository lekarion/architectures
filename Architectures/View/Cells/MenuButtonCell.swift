//
//  MenuButtonCell.swift
//  Architectures
//
//  Created by developer on 27.12.2023.
//

import UIKit

protocol MenuButtonCellInterface: ActionActivationCellInterface {
    var menu: UIMenu? { get set }
    var stateImage: UIImage? { get set }
}

class MenuButtonCell: UITableViewCell {
    @IBOutlet private weak var menuButton: UIButton!
}

extension MenuButtonCell: MenuButtonCellInterface {
    var menu: UIMenu? {
        get { menuButton.menu }
        set { menuButton.menu = newValue }
    }

    var stateImage: UIImage? {
        get { menuButton.image(for: .normal) }
        set { menuButton.setImage(newValue, for: .normal) }
    }

    func activateAction(presenter: UIViewController?) {
        menuButton.gestureRecognizers?.first {
            String(describing: type(of: $0.self)).contains("TouchDownGestureRecognizer")
        }?.touchesBegan([], with: UIEvent())
    }
}
