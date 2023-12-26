//
//  ActionActivationCell.swift
//  Architectures
//
//  Created by Oleg on 26.12.2023.
//

import UIKit.UIViewController

protocol ActionActivationCellInterface: AnyObject {
    func activateAction(presenter: UIViewController?)
}
