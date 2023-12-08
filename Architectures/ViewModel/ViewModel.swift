//
//  ViewModel.swift
//  Architectures
//
//  Created by developer on 08.12.2023.
//

import Foundation
import UIKit.UIImage

protocol VisualItem {
    func testDescription() -> String
}

protocol SchemeItem: VisualItem {
    var identifier: String { get }
    var schemeImage: UIImage? { get }
}

protocol DetailsItem: VisualItem {
    var icon: UIImage? { get }
    var title: String { get }
    var description: String? { get }
}

extension ModelItem {
    func toVisualItem() -> VisualItem? {
        switch self {
        case let dataItem as DataModelItem:
            return ViewModel.Details(modelItem: dataItem)
        default:
            return nil
        }
    }
}

class ViewModel {
    struct Scheme: SchemeItem {
        let identifier: String
        let schemeImage: UIImage?

        init(_ identifier: String, image: UIImage? = nil) {
            self.identifier = identifier
            if let inputImage = image {
                schemeImage = inputImage
            } else {
                schemeImage = UIImage(named: identifier)
            }
        }
    }

    struct Details: DetailsItem {
        var icon: UIImage? { UIImage(named: modelItem.data.iconName ?? "graduationcap.fill") }
        var title: String { modelItem.data.title }
        var description: String? { modelItem.data.description }

        init(modelItem: DataModelItem) {
            self.modelItem = modelItem
        }

        let modelItem: DataModelItem
    }

    private init() {
    }
}

// MARK: -
extension SchemeItem {
    func testDescription() -> String {
        "SchemeItem - \(identifier) - \(schemeImage?.size ?? .zero)"
    }
}

extension DetailsItem {
    func testDescription() -> String {
        "DetailsItem - \(title) - \(description ?? "nil") - \(icon?.size ?? .zero)"
    }
}
