//
//  CustomPresentationSegue.swift
//  Architectures
//
//  Created by developer on 23.12.2023.
//

import UIKit

protocol CustomPresentationSourceInterface: AnyObject {
    var customTransitioningDelegate: UIViewControllerTransitioningDelegate { get }
}

class CustomPresentationSegue: UIStoryboardSegue {
    override func perform() {
        repeat {
            guard let presentationSource = source as? CustomPresentationSourceInterface else { break }

            destination.transitioningDelegate = presentationSource.customTransitioningDelegate
            destination.modalPresentationStyle = .custom

            source.present(destination, animated: true)
            return
        } while false

        // default presentation - modal
        destination.modalPresentationStyle = .automatic
        source.present(destination, animated: true)
    }
}
