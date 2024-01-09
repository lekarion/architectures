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

extension ModelInterface {
    func validateForDuplication(_ items: [ModelItem], dataProvider: DataProviderInterface) -> [DataItemInterface] {
        guard !items.isEmpty else { return [] }

        let itemsToDuplicate: [DataItemInterface] = items.compactMap {
            guard let infoItem = $0 as? DataModelItem else { return nil }
            return Model.DuplicationItemData(with: infoItem.data)
        }

        return dataProvider.duplicate(itemsToDuplicate)
    }

    func duplicate(_ items: [DataItemInterface], dataProvider: DataProviderInterface, imageProvider: ImagesProviderInterface) {
        guard !items.isEmpty else { return }

        let currentItems = dataProvider.reload().compactMap { nil != $0.originalTitle ? $0 : nil }

        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + .seconds(Int.random(in: 3...7))) { [weak self] in
            guard let self = self else { return }

            let newItems: [DataItemInterface] = items.compactMap {
                guard nil != $0.originalTitle, nil != $0.iconName else { return nil }

                imageProvider.cacheImage(for: $0)
                return $0
            }

            guard !newItems.isEmpty else { return }

            dataProvider.merge(newItems + currentItems)
            self.reload()
        }
    }
}
