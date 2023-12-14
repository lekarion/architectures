//
//  MVVMViewModel.swift
//  Architectures
//
//  Created by developer on 08.12.2023.
//

#if USE_COMBINE_FOR_VIEW_ACTIONS
import Combine
#endif // USE_COMBINE_FOR_VIEW_ACTIONS
import Foundation
import UIKit.UIImage

protocol MVVMViewModelInterface: ViewModelInterface {
    var structureBind: GenericBind<[VisualItem]> { get }
    var availableActionsBind: GenericBind<ViewModel.Actions> { get }
}

extension ViewModel {
    class MVVM: MVVMViewModelInterface {
        let structureBind: GenericBind<[VisualItem]>
        let availableActionsBind: GenericBind<ViewModel.Actions>

    #if USE_COMBINE_FOR_VIEW_ACTIONS
        var sortingOrder: Model.SortingOrder { model.sortingOrder }

        func setup(with actionInterface: ViewModelActionInterface) {
            actionInterface.actionEvent.sink { [weak self] in
                guard let self = self else { return }

                switch $0 {
                case .changeSortingOrder(let order):
                    self.model.sortingOrder = order
                    self.settings?.sortingOrder = order.toSortingOrder()

                    guard !self.model.structure.value.isEmpty else { break }
                    self.model.reload()
                case .clear:
                    self.model.clear()
                case .reload:
                    self.model.reload()
                }
            }.store(in: &bag)
        }
    #else
        var sortingOrder: Model.SortingOrder {
            get { model.sortingOrder }
            set {
                model.sortingOrder = newValue
                settings?.sortingOrder = newValue.toSortingOrder()

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
    #endif // USE_COMBINE_FOR_VIEW_ACTIONS

        init() {
            guard let appCoordinator = UIApplication.shared.delegate as? AppCoordinator else {
                fatalError("Invalid app state")
            }

            settings = appCoordinator.settingsProvider(for: "com.mvvm.settings")

            model = Model.MVVM(with: appCoordinator.dataProvider(for: "com.mvvm.data"))
            model.sortingOrder = Model.SortingOrder(with: settings?.sortingOrder ?? .none)

            structureBind = GenericBind(value: Self.emptyStructure + model.structure.value.compactMap { $0.toVisualItem() })
            availableActionsBind = GenericBind(value: Self.availableActions(for: structureBind.value))

            modelCancellable = model.structure.bind { [weak self] structure in
                guard let self = self else { return }

                let newStucture = Self.emptyStructure + structure.compactMap { $0.toVisualItem() }
                DispatchQueue.main.async {
                    self.structureBind.value = newStucture
                    self.availableActionsBind.value = Self.availableActions(for: self.structureBind.value)
                }
            }
        }

        deinit {
            modelCancellable?.cancel()
        }

        private let settings: SettingsProviderInterface?
        private let model: Model.MVVM
        private var modelCancellable: BindCancellable?
    #if USE_COMBINE_FOR_VIEW_ACTIONS
        private var bag = Set<AnyCancellable>()
    #endif // USE_COMBINE_FOR_VIEW_ACTIONS
    }
}

private extension ViewModel.MVVM {
    static let emptyStructure = [ViewModel.Scheme("Schemes/mvvm-scheme")]
    static func availableActions(for structure: [VisualItem]) -> ViewModel.Actions {
        (emptyStructure.count == structure.count) ? .reload : .all
    }
}

extension MVVMViewModelInterface {
    var structure: [VisualItem] { structureBind.value }
}
