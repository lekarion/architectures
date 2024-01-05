//
//  CombineModel.swift
//  Architectures
//
//  Created by developer on 11.12.2023.
//

import Combine
import Foundation

protocol CombineModelInterface: ModelInterface {
    var structureBind: AnyPublisher<[ModelItem], Never> { get }
}

extension Model {
    class CombineModel: CombineModelInterface {
        var structureBind: AnyPublisher<[ModelItem], Never> { structureSubject.eraseToAnyPublisher() }
        private(set) var structure = [ModelItem]() {
            didSet {
                structureSubject.send(structure)
            }
        }

        var sortingOrder: Model.SortingOrder = .none {
            didSet {
                guard oldValue != sortingOrder else { return }

                dataProvider.sortingOrder = sortingOrder.toDataProviderSortingOrder
                loaded = false
            }
        }

        func clear() {
            guard !structure.isEmpty else { return }

            structure = []
            loaded = false
        }

        func reset() {
            dataProvider.merge([])

            loaded = false
            reload()
        }

        func reload() {
            guard !loaded else { return }

            structure = dataProvider.reload().map {
                InfoItem(data: ItemData(iconName: "Emblems/\($0.iconName ?? $0.title)", title: $0.title.localized, description: $0.description?.localized))
            }
            loaded = true
        }

        func validateForDuplication(_ items: [ModelItem]) -> [DataItemInterface] {
            validateForDuplication(items, dataProvider: dataProvider)
        }

        func duplicate(_ items: [DataItemInterface]) {
            loaded = false
            duplicate(items, dataProvider: dataProvider, imageProvider: imageProvider)
        }


        init(with dataProvider: DataProviderInterface, imageProvider: ImagesProviderInterface) {
            self.dataProvider = dataProvider
            self.imageProvider = imageProvider
        }

        private let structureSubject = PassthroughSubject<[ModelItem], Never>()
        private let dataProvider: DataProviderInterface
        private let imageProvider: ImagesProviderInterface
        private var loaded = false
    }
}
