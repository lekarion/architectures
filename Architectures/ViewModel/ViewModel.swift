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

protocol ViewModelInterface: AnyObject {
    var rawStructure: [VisualItem] { get }
    var sortingOrder: Model.SortingOrder { get set }

    func reloadData()
    func clearData()
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

    struct Actions: OptionSet {
        let rawValue: Int

        static let clear = Actions(rawValue: 1 << 0)
        static let reload = Actions(rawValue: 1 << 1)
        static let changeSortingOrder = Actions(rawValue: 1 << 2)

        static let all: Actions = [.clear, .reload, .changeSortingOrder]
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