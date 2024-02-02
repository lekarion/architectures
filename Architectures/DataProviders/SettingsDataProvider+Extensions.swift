//
//  SettingsDataProvider+Extensions.swift
//  Architectures
//
//  Created by developer on 26.12.2023.
//

import Foundation

extension SettingsDataProvider {
    enum SDTPresentationAnimationDirection: String {
        case fromTopToBottom
        case fromBottomToTop
        case fromLeftToRight
        case fromRightToLeft
        case centerZoom

        init(_ direction: PresentationAnimationDirection) {
            switch direction {
            case .centerZoom:
                self = .centerZoom
            case .fromBottomToTop:
                self = .fromBottomToTop
            case .fromLeftToRight:
                self = .fromLeftToRight
            case .fromRightToLeft:
                self = .fromRightToLeft
            case .fromTopToBottom:
                self = .fromTopToBottom
            }
        }

        func toPresentationAnimationDirection() -> PresentationAnimationDirection {
            switch self {
            case .centerZoom:
                return .centerZoom
            case .fromBottomToTop:
                return .fromBottomToTop
            case .fromLeftToRight:
                return .fromLeftToRight
            case .fromRightToLeft:
                return .fromRightToLeft
            case .fromTopToBottom:
                return .fromTopToBottom
            }
        }
    }
}
