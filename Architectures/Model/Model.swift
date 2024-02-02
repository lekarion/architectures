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
    var imageProvider: ImagesProviderInterface? { get }
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

        init(with dataItem: DataItemInterface) {
            let optionalTitle: String
            if let testTitle = dataItem.originalTitle {
                self.title = String(format: NSLocalizedString("%@ (Duplicated)", comment: ""), testTitle.localized)
                optionalTitle = testTitle
            } else {
                self.title = dataItem.title.localized
                optionalTitle = dataItem.title
            }

            self.iconName = dataItem.iconName ?? optionalTitle
            self.description = dataItem.description?.localized
        }
    }

    class InfoItem: DataModelItem {
        let data: ItemData
        var imageProvider: ImagesProviderInterface? { provider }

        init(data: ItemData, imageProvider: ImagesProviderInterface?) {
            self.data = data
            self.provider = imageProvider
        }

        private weak var provider: ImagesProviderInterface?
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
