//
//  Model.swift
//  Architectures
//
//  Created by developer on 08.12.2023.
//

import Foundation

protocol ModelItem {
    func testDescription() -> String
}

protocol DataModelItem: ModelItem {
    var data: Model.ItemData { get }
}

protocol ModelInterface: AnyObject {
    var structure: [ModelItem] { get }
    var sortingOrder: Model.SortingOrder { get set }

    func clear()
    func reload()
}

class Model {
    struct ItemData {
        let iconName: String?
        let title: String
        let description: String?
    }

    class InfoItem: DataModelItem {
        let data: ItemData

        init(data: ItemData) {
            self.data = data
        }
    }

    enum SortingOrder: CaseIterable {
        case none, ascending, descending
    }

    private init() {
    }
}

extension Model.SortingOrder {
    var toDataProviderSortingOrder: SortingOrder {
        switch self {
        case .none:
            return .none
        case .ascending:
            return .ascending
        case .descending:
            return .descending
        }
    }
}

extension DataModelItem {
    func testDescription() -> String {
        "\(data.title) - \(data.iconName ?? "nil") - \(data.description ?? "nil")"
    }
}
