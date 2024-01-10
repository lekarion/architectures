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
    func reset()
    func reload()

    func validateForDuplication(_ items: [ModelItem]) -> [DataItemInterface]
    func duplicate(_ items: [DataItemInterface])
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

    static let dataProcessingQueue = {
        DispatchQueue(label: "com.model.dataProcessingQueue", qos: .background)
    }()
}
