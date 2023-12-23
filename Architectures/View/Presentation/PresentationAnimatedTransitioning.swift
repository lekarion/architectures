//
//  PresentationAnimatedTransitioning.swift
//  Architectures
//
//  Created by developer on 23.12.2023.
//

import UIKit

class PresentationAnimatedTransitioning: NSObject {
    let presentationAnimation: PresentationAnimationDirection
    let presentationDuartion: TimeInterval
    let isPresentation: Bool
    
    init(presentationAnimation: PresentationAnimationDirection, duration: TimeInterval, isPresentation: Bool) {
        self.presentationAnimation = presentationAnimation
        self.isPresentation = isPresentation
        self.presentationDuartion = duration
        
        super.init()
    }
}

// MARK: -
extension PresentationAnimatedTransitioning: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return presentationDuartion
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let controller = transitionContext.viewController(forKey: isPresentation ? .to : .from) else { return }
        
        let presentedFrame = transitionContext.finalFrame(for: controller)
        guard !presentedFrame.isEmpty else { return }
        
        var dismissedFrame = presentedFrame
        switch presentationAnimation {
        case .centerZoom:
            let minRectSize = CGSize(width: 2.0, height: 2.0)
            dismissedFrame.origin.x += (dismissedFrame.size.width - minRectSize.width) * 0.5
            dismissedFrame.size.width = minRectSize.width
            dismissedFrame.origin.y += (dismissedFrame.size.height - minRectSize.height) * 0.5
            dismissedFrame.size.height = minRectSize.height
        case .fromBottomToTop:
            dismissedFrame.origin.y = transitionContext.containerView.frame.maxY
        case .fromTopToBottom:
            dismissedFrame.origin.y = transitionContext.containerView.frame.origin.y - dismissedFrame.size.height
        case .fromLeftToRight:
            dismissedFrame.origin.x = transitionContext.containerView.frame.origin.x - dismissedFrame.size.width
        case .fromRightToLeft:
            dismissedFrame.origin.x = transitionContext.containerView.frame.maxX
        }
        
        let isPresenting = isPresentation
        
        let fromFrame: CGRect
        let toFrame: CGRect
        
        if isPresenting {
            fromFrame = dismissedFrame
            toFrame = presentedFrame
        }
        else {
            fromFrame = presentedFrame
            toFrame = dismissedFrame
        }
        
        let controllerView: UIView = transitionContext.view(forKey: isPresenting ? .to : .from) ?? controller.view
        let animationView: UIView
        
        if isPresenting {
            controllerView.frame = CGRect(origin: .zero, size: toFrame.size) // to make snapshot with right size
            animationView = controllerView.snapshotView(afterScreenUpdates: true) ?? UIView(frame: .zero)
        }
        else {
            animationView = controllerView.snapshotView(afterScreenUpdates: true) ?? UIView(frame: .zero)
            controllerView.removeFromSuperview()
        }
        
        transitionContext.containerView.addSubview(animationView)
        animationView.frame = fromFrame
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext)) {
            animationView.frame = toFrame
        }
        completion: { completed in
            if completed {
                animationView.frame = toFrame
                animationView.removeFromSuperview()
                
                if isPresenting {
                    transitionContext.containerView.addSubview(controllerView)
                    controllerView.frame = toFrame
                    controllerView.setNeedsLayout()
                }
            }
            transitionContext.completeTransition(completed)
        }
    }
}
