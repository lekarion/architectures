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

                    guard !self.model.structure.isEmpty else { break }
                    self.model.reload()
                case .clear:
                    self.model.clear()
                case .reset:
                    self.model.reset()
                case .reload:
                    self.model.reload()
                case .duplicate(let items):
                    let dataItems = self.model.validateForDuplication(items.compactMap({ $0.toModelItem() }))
                    guard !dataItems.isEmpty else { break }

                    self.model.duplicate(dataItems)
                }
            }.store(in: &bag)
        }
    #else
        var sortingOrder: Model.SortingOrder {
            get { model.sortingOrder }
            set {
                model.sortingOrder = newValue
                settings?.sortingOrder = newValue.toSortingOrder()

                guard !model.structure.isEmpty else { return }
                model.reload()
            }
        }

        func reloadData() {
            model.reload()
        }

        func clearData() {
            model.clear()
        }

        func resetData() {
            model.reset()
        }
    #endif // USE_COMBINE_FOR_VIEW_ACTIONS

        func validateForDuplication(_ items: [VisualItem]) -> Bool {
            !model.validateForDuplication(items.compactMap({ $0.toModelItem() })).isEmpty
        }

        func duplicate(_ items: [VisualItem]) {
            let dataItems = model.validateForDuplication(items.compactMap({ $0.toModelItem() }))
            guard !dataItems.isEmpty else { return }

            model.duplicate(dataItems)
        }

        init(_ identifier: String? = nil) {
            guard let appCoordinator = UIApplication.shared.delegate as? AppCoordinator else {
                fatalError("Invalid app state")
            }

            let baseIdentifier = identifier ?? "com.mvvm"

            settings = appCoordinator.settingsProvider(for: "\(baseIdentifier).settings")

            let providersIdentifier = "\(baseIdentifier).data"
            model = Model.PlainModel(with: appCoordinator.dataProvider(for: providersIdentifier), imageProvider: appCoordinator.imagesProvider(for: providersIdentifier))
            model.sortingOrder = Model.SortingOrder(with: settings?.sortingOrder ?? .none)

            structureBind = GenericBind(value: Self.emptyStructure + model.structure.compactMap { $0.toVisualItem() })
            availableActionsBind = GenericBind(value: Self.availableActions(for: structureBind.value))

            modelCancellable = model.structureBind.bind { [weak self] structure in
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
        private let model: Model.PlainModel
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
