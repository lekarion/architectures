//
//  CustomPresentation.swift
//  Architectures
//
//  Created by developer on 23.12.2023.
//

import UIKit

enum PresentationDimmingStyle {
    /// prevent dimming
    case none
    /// dimming with color
    case color
    /// dimming using visual effect (blur)
    case effect
}

protocol PresentationSettingsProvider: AnyObject {
    var style: PresentationDimmingStyle { get }
    var color: UIColor { get }
    var contentInsets: UIEdgeInsets { get }
}

// MARK: ###
enum PresentationAnimationDirection {
    case fromTopToBottom
    case fromBottomToTop
    case fromLeftToRight
    case fromRightToLeft
    case centerZoom
}

protocol PresentationAnimationSettingsProvider {
    var presentingAnimation: PresentationAnimationDirection { get }
    var presentingDuration: TimeInterval { get }
    
    var dismissingAnimation: PresentationAnimationDirection { get }
    var dismissingDuration: TimeInterval { get }
}

// MARK: -
extension PresentationAnimationDirection {
    func reverced() -> PresentationAnimationDirection {
        let result: PresentationAnimationDirection
        switch self {
        case .fromBottomToTop:
            result = .fromTopToBottom
        case .fromTopToBottom:
            result = .fromBottomToTop
        case .fromLeftToRight:
            result = .fromRightToLeft
        case .fromRightToLeft:
            result = .fromLeftToRight
        case .centerZoom:
            result = .centerZoom
        }
        return result
    }
}

extension PresentationSettingsProvider {
    var style: PresentationDimmingStyle { .color }
    var color: UIColor { UIColor.darkGray.withAlphaComponent(0.85) }
    var contentInsets: UIEdgeInsets { UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0) }
}

extension PresentationAnimationSettingsProvider {
    var presentingAnimation: PresentationAnimationDirection { .centerZoom }
    var presentingDuration: TimeInterval { 0.3 }
    
    var dismissingAnimation: PresentationAnimationDirection { .centerZoom }
    var dismissingDuration: TimeInterval { 0.3 }
}
