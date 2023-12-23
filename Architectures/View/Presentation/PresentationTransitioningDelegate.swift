//
//  PresentationTransitioningDelegate.swift
//  Architectures
//
//  Created by developer on 23.12.2023.
//

import UIKit

class PresentationTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let result = PresentationController(presentedViewController: presented, presenting: presenting)

        if let provider = source as? PresentationSettingsProvider {
            result.settingsProvider = provider
        } else if let provider = presented as? PresentationSettingsProvider {
            result.settingsProvider = provider
        }

        return result
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        var settingsProvider: PresentationAnimationSettingsProvider = self
        if let provider = source as? PresentationAnimationSettingsProvider {
            settingsProvider = provider
        } else if let provider = presented as? PresentationAnimationSettingsProvider {
            settingsProvider = provider
        }

        backAnimation = settingsProvider.dismissingAnimation.reverced()
        backDuration = settingsProvider.dismissingDuration

        return PresentationAnimatedTransitioning(presentationAnimation: settingsProvider.presentingAnimation, duration: settingsProvider.presentingDuration, isPresentation: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentationAnimatedTransitioning(presentationAnimation: backAnimation, duration: backDuration, isPresentation: false)
    }
    
    // MARK: ### Private ###
    private var backAnimation: PresentationAnimationDirection = .centerZoom
    private var backDuration: TimeInterval = 0.3
}

extension PresentationTransitioningDelegate: PresentationAnimationSettingsProvider {
}
