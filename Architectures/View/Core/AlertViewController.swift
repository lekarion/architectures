//
//  AlertViewController.swift
//  Architectures
//
//  Created by developer on 08.01.2024.
//

import UIKit

protocol AlertViewControllerInterface: AnyObject {
    var delegate: AlertViewControllerDelegate? { get set }
}

protocol AlertViewControllerDelegate: AnyObject {
    func alertViewController(_ controller: AlertViewController, didDissmissWithAction action: AlertDismissAction)
}

enum AlertDismissAction {
    case ok, cancel
}

class AlertViewController: UIViewController, AlertViewControllerInterface {
    weak var delegate: AlertViewControllerDelegate?

    @IBAction func onDefaultAction(_ sender: Any) {
        delegate?.alertViewController(self, didDissmissWithAction: .ok)
    }

    @IBAction func onDismissAction(_ sender: Any) {
        delegate?.alertViewController(self, didDissmissWithAction: .cancel)
    }
}
