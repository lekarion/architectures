//
//  PlainModel.swift
//  Architectures
//
//  Created by developer on 08.12.2023.
//

import Foundation

protocol PlainModelInterface: ModelInterface {
    var structureBind: GenericBind<[ModelItem]> { get }
}

extension Model {
    class PlainModel: PlainModelInterface {
        let structureBind = GenericBind(value: [ModelItem]())

        var sortingOrder: Model.SortingOrder = .none {
            didSet {
                guard oldValue != sortingOrder else { return }

                dataProvider.sortingOrder = sortingOrder.toDataProviderSortingOrder
                loaded = false
            }
        }

        func clear() {
            guard !structureBind.value.isEmpty else { return }

            structureBind.value = []
            loaded = false
        }

        func reset() {
            dataProvider.merge([])

            loaded = false
            reload()
        }

        func reload() {
            guard !loaded else { return }

            var newStructure = [ModelItem]()
            Model.dataProcessingQueue.sync {
                newStructure = dataProvider.reload().map {
                    InfoItem(data: ItemData(iconName: "Emblems/\($0.iconName ?? $0.title)", title: $0.localizedTitle, description: $0.description?.localized))
                }
            }

            structureBind.value = newStructure
            loaded = true
        }

        func validateForDuplication(_ items: [ModelItem]) -> [DataItemInterface] {
            Model.validateForDuplication(items, dataProvider: dataProvider)
        }

        func duplicate(_ items: [DataItemInterface]) {
            loaded = false
            Model.duplicate(items, dataProvider: dataProvider, imageProvider: imageProvider) { [weak self] in
                guard let self = self else { return }

                self.loaded = false
                self.reload()
            }
        }

        init(with dataProvider: DataProviderInterface, imageProvider: ImagesProviderInterface) {
            self.dataProvider = dataProvider
            self.imageProvider = imageProvider
        }

        private let dataProvider: DataProviderInterface
        private let imageProvider: ImagesProviderInterface
        private var loaded = false
    }
}

extension PlainModelInterface {
    var structure: [ModelItem] { structureBind.value }
}
