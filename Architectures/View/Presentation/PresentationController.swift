//
//  PresentationController.swift
//  Architectures
//
//  Created by developer on 23.12.2023.
//

import UIKit

class PresentationController: UIPresentationController {
    weak var settingsProvider: PresentationSettingsProvider?
    
    override func presentationTransitionWillBegin() {
        guard let rootContainerView = containerView else { return }
        
        dimmingView = nil
        
        let provider = settingsProvider ?? self
        switch provider.style {
        case .color:
            let view = UIView(frame: .zero)
            let layer = view.layer
            layer.backgroundColor = provider.color.cgColor
            dimmingView = view
        case .effect:
            let blur = UIBlurEffect(style: .dark)
            let view = UIVisualEffectView(effect: blur)
            let subview = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blur))
            view.contentView.addSubview(subview)
            dimmingView = view
            break
        default:
            break
        }
        
        guard let subview = dimmingView else { return }
        subview.translatesAutoresizingMaskIntoConstraints = false
        
        rootContainerView.insertSubview(subview, at: 0)
        rootContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[subview]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["subview": subview]))
        rootContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[subview]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["subview": subview]))
        
        guard let coordinator = presentedViewController.transitionCoordinator else { return }
        
        subview.alpha = 0.0
        coordinator.animate { _ in
            subview.alpha = 1.0
        } completion: { _ in
            subview.alpha = 1.0
        }
    }
    
    override func dismissalTransitionWillBegin() {
        guard let subview = dimmingView else { return }
        guard let coordinator = presentedViewController.transitionCoordinator else { return }
        
        coordinator.animate { _ in
            subview.alpha = 0.0
        } completion: { _ in
            subview.removeFromSuperview()
        }
    }
    
    override func containerViewWillLayoutSubviews() {
        guard let targetView = presentedView else { return }
        targetView.frame = frameOfPresentedViewInContainerView
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        let contentFrame = containerView?.frame ?? .zero
        guard !contentFrame.isEmpty else { return .zero }
        
        let provider = settingsProvider ?? self
        
        var frame: CGRect = .zero
        frame.size = size(forChildContentContainer: presentedViewController, withParentContainerSize: contentFrame.size)
        frame.origin.x = provider.contentInsets.left
        frame.origin.y = provider.contentInsets.top + (contentFrame.size.height - (provider.contentInsets.top + provider.contentInsets.bottom) - frame.size.height) * 0.5
        
        return frame
    }
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        guard let view = presentedView else { return parentSize }
        
        let provider = settingsProvider ?? self
        var area = CGRect(origin: .zero, size: parentSize).inset(by: provider.contentInsets)
        
        guard !area.isEmpty else { return parentSize }
        
        var frame = view.frame
        frame.size.width = area.width
        view.frame = frame
        view.layoutSubviews()
        
        var testSize = UIView.layoutFittingCompressedSize
        testSize.width = area.size.width
        area.size.height = view.systemLayoutSizeFitting(testSize).height
        
        return area.size
    }
    
    // MARK: ### Private ###
    private var dimmingView: UIView? = nil
}

// MARK: -
extension PresentationController: PresentationSettingsProvider {
}
