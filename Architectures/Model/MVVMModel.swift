//
//  MVVMModel.swift
//  Architectures
//
//  Created by developer on 08.12.2023.
//

import Foundation

protocol MVVMModelInterface: ModelInterface {
    var structure: GenericBind<[ModelItem]> { get }
}

extension Model {
    class MVVM: MVVMModelInterface {
        let structure = GenericBind(value: [ModelItem]())

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

extension MVVMModelInterface {
    var rawStructure: [ModelItem] { structure.value }
}
