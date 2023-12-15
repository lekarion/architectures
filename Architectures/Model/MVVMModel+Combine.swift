//
//  MVVMModel+Combine.swift
//  Architectures
//
//  Created by developer on 11.12.2023.
//

import Combine
import Foundation

protocol MVVMModelCombineInterface: ModelInterface {
    var structureBind: AnyPublisher<[ModelItem], Never> { get }
}

extension Model {
    class MVVMCombine: MVVMModelCombineInterface {
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

        func reload() {
            guard !loaded else { return }

            structure = dataProvider.reload().map {
                InfoItem(data: ItemData(iconName: "Emblems/\($0.iconName ?? $0.title)", title: $0.title.localized, description: $0.description?.localized))
            }
            loaded = true
        }

        init(with dataProvider: DataProviderInterface) {
            self.dataProvider = dataProvider
        }

        private let structureSubject = PassthroughSubject<[ModelItem], Never>()
        private let dataProvider: DataProviderInterface
        private var loaded = false
    }
}
