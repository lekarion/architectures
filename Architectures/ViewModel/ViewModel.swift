//
//  ViewModel.swift
//  Architectures
//
//  Created by developer on 08.12.2023.
//

#if USE_COMBINE_FOR_VIEW_ACTIONS
import Combine
#endif // USE_COMBINE_FOR_VIEW_ACTIONS
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

extension VisualItem {
    func toModelItem() -> ModelItem? {
        switch self {
        case let holder as DataModelItemHolder:
            return holder.modelItem
        default:
            return nil
        }
    }
}

#if USE_COMBINE_FOR_VIEW_ACTIONS
protocol ViewModelInterface: AnyObject {
    var structure: [VisualItem] { get }
    var sortingOrder: Model.SortingOrder { get }

    func setup(with actionInterface: ViewModelActionInterface)
}

protocol ViewModelActionInterface: AnyObject {
    var actionEvent: AnyPublisher<ViewModelAction, Never> { get }
}

enum ViewModelAction {
    case changeSortingOrder(order: Model.SortingOrder)
    case clear, reload, reset
    case duplicate(items: [VisualItem])
}
#else
protocol ViewModelActionInterface: AnyObject { // dummy
}

protocol ViewModelInterface: AnyObject {
    var structure: [VisualItem] { get }
    var sortingOrder: Model.SortingOrder { get set }

    func reloadData()
    func clearData()
    func resetData()

    func validateForDuplication(_ items: [VisualItem]) -> Bool
    func duplicate(_ items: [VisualItem])
}
#endif // USE_COMBINE_FOR_VIEW_ACTIONS

private protocol DataModelItemHolder {
    var modelItem: DataModelItem { get }
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

    class Details: DetailsItem, DataModelItemHolder {
        var icon: UIImage? { iconImage }
        var title: String { modelItem.data.title }
        var description: String? { modelItem.data.description }

        init(modelItem: DataModelItem) {
            self.modelItem = modelItem
        }

        fileprivate let modelItem: DataModelItem
        private lazy var iconImage: UIImage? = {
            guard let iconName = modelItem.data.iconName else { return UIImage(systemName: "graduationcap.fill") }
            if let loadedImage = modelItem.imageProvider?.image(named: iconName) { return loadedImage }
            return UIImage(systemName: "graduationcap.fill")
        }()
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

extension Model.SortingOrder {
    func toSortingOrder() -> SortingOrder {
        switch self {
        case .none:
            return .none
        case .ascending:
            return .ascending
        case .descending:
            return .descending
        }
    }

    init(with order: SortingOrder) {
        switch order {
        case .none:
            self = .none
        case .ascending:
            self = .ascending
        case .descending:
            self = .descending
        }
    }
}
