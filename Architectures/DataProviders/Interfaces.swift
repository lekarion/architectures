//
//  Interfaces.swift
//  Architectures
//
//  Created by developer on 07.12.2023.
//

import Foundation
import UIKit.UIColor
import UIKit.UIImage

protocol TestDescriptionInterface {
    func testDescription() -> String
}

// MARK: - ### Data provider ### -
protocol DataProviderInterface: AnyObject {
    var sortingOrder: SortingOrder { get set }

    func reload() -> [DataItemInterface]
    func merge(_ items: [DataItemInterface], autoFlush: Bool)
    func duplicate(_ items: [DataItemInterface]) -> [DataItemInterface]

    func flush()
}

protocol DataItemInterface: TestDescriptionInterface {
    var iconName: String? { get }
    var title: String { get }
    var originalTitle: String? { get } // the title of the original element that was duplicated
    var description: String? { get }
}

// MARK: - ### Settings provider ### -
protocol SettingsProviderInterface: AnyObject {
    var sortingOrder: SortingOrder { get set }
    var presentationInAnimationDirection: PresentationAnimationDirection? { get set }
    var presentationOutAnimationDirection: PresentationAnimationDirection? { get set }
    var presentationDimmingColor: UIColor? { get set }
}

// MARK: - ### Settings provider ### -
protocol ImagesProviderInterface: AnyObject {
    func image(for item: DataItemInterface) -> UIImage?
    func cacheImage(for item: DataItemInterface)
}

// MARK: -
enum SortingOrder: String {
    case none, ascending, descending
}

extension DataItemInterface {
    func testDescription() -> String {
        "\(title) - \(description ?? "nil") - \(iconName ?? "nil")"
    }

    var localizedTitle: String {
        if let testTitle = originalTitle {
            return String(format: NSLocalizedString("%@ (Duplicated)", comment: ""), testTitle.localized)
        } else {
            return title.localized
        }
    }
}
