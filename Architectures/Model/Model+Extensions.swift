//
//  Model+Extensions.swift
//  Architectures
//
//  Created by developer on 04.01.2024.
//

import Foundation

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

private extension Model {
    struct DuplicationItemData: DataItemInterface {
        let iconName: String?
        let title: String
        let originalTitle: String? = nil
        let description: String?

        init(with item: ItemData) {
            iconName = item.iconName
            title = item.title
            description = item.description
        }
    }
}

extension Model {
    static func validateForDuplication(_ items: [ModelItem], dataProvider: DataProviderInterface) -> [DataItemInterface] {
        guard !items.isEmpty else { return [] }

        let itemsToDuplicate: [DataItemInterface] = items.compactMap {
            guard let infoItem = $0 as? DataModelItem else { return nil }
            return Model.DuplicationItemData(with: infoItem.data)
        }

        var duplicates = [DataItemInterface]()
        Self.dataProcessingQueue.sync {
            duplicates = dataProvider.duplicate(itemsToDuplicate)
        }

        return duplicates
    }

    static func duplicate(_ items: [DataItemInterface], dataProvider: DataProviderInterface, imageProvider: ImagesProviderInterface, completion: @escaping () -> Void) {
        guard !items.isEmpty else { return }

        Self.dataProcessingQueue.asyncAfter(deadline: .now() + .seconds(Int.random(in: 3...7))) {
            let newItems: [DataItemInterface] = items.compactMap {
                guard nil != $0.originalTitle, nil != $0.iconName else { return nil }

                imageProvider.cacheImage(for: $0)
                return $0
            }

            guard !newItems.isEmpty else { return }

            let currentItems = dataProvider.reload().compactMap { nil != $0.originalTitle ? $0 : nil }
            dataProvider.merge(newItems + currentItems, autoFlush: true)

            DispatchQueue.main.async {
                completion()
            }
        }
    }
}
