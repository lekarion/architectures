//
//  MVVMModel+Combine.swift
//  Architectures
//
//  Created by developer on 11.12.2023.
//

import Combine
import Foundation

protocol MVVMModelCombineInterface: ModelInterface {
    var structure: CurrentValueSubject<[ModelItem], Never> { get }
}

extension Model {
    class MVVMCombine: MVVMModelCombineInterface {
        let structure = CurrentValueSubject<[ModelItem], Never>([])

        var sortingOrder: Model.SortingOrder = .none {
            didSet {
                guard oldValue != sortingOrder else { return }

                dataProvider.sortingOrder = sortingOrder.toDataProviderSortingOrder
                loaded = false
            }
        }

        func clear() {
            guard !structure.value.isEmpty else { return }

            structure.value = []
            loaded = false
        }

        func reload() {
            guard !loaded else { return }

            structure.value = dataProvider.reload().map {
                InfoItem(data: ItemData(iconName: "Emblems/\($0)", title: "\($0).title".localized, description: "\($0).description".localized))
            }
            loaded = true
        }

        init(with dataProvider: DataProviderInterface) {
            self.dataProvider = dataProvider
        }

        private let dataProvider: DataProviderInterface
        private var loaded = false
    }
}

extension MVVMModelCombineInterface {
    var rawStructure: [ModelItem] { structure.value }
}
