//
//  MVVMViewModel.swift
//  Architectures
//
//  Created by developer on 08.12.2023.
//

import Foundation
import UIKit.UIImage

extension ViewModel {
    class MVVM {
        let structure: GenericBind<[VisualItem]>

        var sortingOrder: Model.SortingOrder {
            get { model.sortingOrder }
            set { model.sortingOrder = newValue }
        }

        func reloadData() {
            model.reload()
        }

        func clearData() {
            model.clear()
        }

        init() {
            guard let appCoordinator = UIApplication.shared.delegate as? AppCoordinator else {
                fatalError("Invalid app state")
            }

            model = Model.MVVM(with: appCoordinator.dataProvider(for: "com.mvvm.data"))
            structure = GenericBind(value: emptyStructure + model.structure.value.compactMap { $0.toVisualItem() })

            modelCancellable = model.structure.bind { [weak self] structure in
                guard let self = self else { return }

                self.workQueue.async {
                    self.structure.value = self.emptyStructure + structure.compactMap { $0.toVisualItem() }
                }
            }
        }

        private let model: Model.MVVM
        private let emptyStructure = [Scheme("Schemes/mvvm-scheme")]
        private let workQueue = DispatchQueue(label: "com.developer.viewModelQueue", qos: .default)

        private var modelCancellable: BindCancellable?
    }
}
