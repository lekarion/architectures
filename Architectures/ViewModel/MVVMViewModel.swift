//
//  MVVMViewModel.swift
//  Architectures
//
//  Created by developer on 08.12.2023.
//

import Foundation
import UIKit.UIImage

protocol MVVMViewModelInterface: AnyObject {
    var structure: GenericBind<[VisualItem]> { get }
    var availableActions: GenericBind<ViewModel.Actions> { get }
}

extension ViewModel {
    class MVVM: MVVMViewModelInterface {
        let structure: GenericBind<[VisualItem]>
        let availableActions: GenericBind<ViewModel.Actions>

        var sortingOrder: Model.SortingOrder {
            get { model.sortingOrder }
            set {
                model.sortingOrder = newValue

                guard !model.structure.value.isEmpty else { return }
                model.reload()
            }
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
            structure = GenericBind(value: Self.emptyStructure + model.structure.value.compactMap { $0.toVisualItem() })
            availableActions = GenericBind(value: Self.availableActions(for: structure.value))

            modelCancellable = model.structure.bind { [weak self] structure in
                guard let self = self else { return }

                self.workQueue.async {
                    self.structure.value = Self.emptyStructure + structure.compactMap { $0.toVisualItem() }
                    self.availableActions.value = Self.availableActions(for: self.structure.value)
                }
            }
        }

        private let model: Model.MVVM
        private let workQueue = DispatchQueue(label: "com.developer.viewModelQueue", qos: .default)

        private var modelCancellable: BindCancellable?
    }
}

private extension ViewModel.MVVM {
    static let emptyStructure = [ViewModel.Scheme("Schemes/mvvm-scheme")]
    static func availableActions(for structure: [VisualItem]) -> ViewModel.Actions {
        (emptyStructure.count == structure.count) ? .all : .reload
    }
}
