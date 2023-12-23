//
//  CustomPresentationSegue.swift
//  Architectures
//
//  Created by developer on 23.12.2023.
//

import UIKit

class CustomPresentationSegue: UIStoryboardSegue {
    override func perform() {
        destination.modalPresentationStyle = .popover
        source.present(destination, animated: true)
    }
}
