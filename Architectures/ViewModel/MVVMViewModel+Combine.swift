//
//  MVVMViewModel+Combine.swift
//  Architectures
//
//  Created by developer on 11.12.2023.
//

import Combine
import Foundation
import UIKit

protocol MVVMViewModelCombineInterface: ViewModelInterface {
    var structure: CurrentValueSubject<[VisualItem], Never> { get }
    var availableActions: CurrentValueSubject<ViewModel.Actions, Never> { get }
}

extension ViewModel {
    class MVVMCombine: MVVMViewModelCombineInterface {
        let structure = CurrentValueSubject<[VisualItem], Never>([])
        let availableActions = CurrentValueSubject<ViewModel.Actions, Never>([])

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

            model = Model.MVVMCombine(with: appCoordinator.dataProvider(for: "com.mvvm.combine.data"))

            modelCancellable = model.structure.receive(on: workQueue).sink { [weak self] value in
                guard let self = self else { return }

                let visualValue = value.compactMap({ $0.toVisualItem() })
                self.structure.send(Self.emptyStructure + visualValue)
                self.availableActions.send(Self.availableActions(for: self.structure.value))
            }
        }

        deinit {
            modelCancellable?.cancel()
        }

        private let model: Model.MVVMCombine
        private let workQueue = DispatchQueue(label: "com.developer.viewModelQueue", qos: .default)

        private var modelCancellable: AnyCancellable?
    }
}

private extension ViewModel.MVVMCombine {
    static let emptyStructure = [ViewModel.Scheme("Schemes/mvvm-scheme")]
    static func availableActions(for structure: [VisualItem]) -> ViewModel.Actions {
        (emptyStructure.count == structure.count) ? .reload : .all
    }
}

extension MVVMViewModelCombineInterface {
    var rawStructure: [VisualItem] { structure.value }
}
