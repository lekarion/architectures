//
//  MVPPresenter.swift
//  Architectures
//
//  Created by developer on 15.12.2023.
//

import UIKit

extension Presenter {
    class MVP: PresenterInterface {
    #if USE_BINDING_FOR_PALIN_MVP
    #else
        private(set) var structure: [VisualItem] {
            didSet {
                view?.handle(update: .structure)
            }
        }

        private(set) var availableActions: Presenter.Actions = [] {
            didSet {
                view?.handle(update: .availableActions)
            }
        }
    #endif // USE_BINDING_FOR_PALIN_MVP

        private(set) var sortingOrder: Model.SortingOrder {
            get { model?.sortingOrder ?? .none }
            set { model?.sortingOrder = newValue }
        }

        func handle(action: Presenter.Action) {
            switch action {
            case .changeSortingOrder(let order):
                guard availableActions.contains(.changeSortingOrder) else { break }

                sortingOrder = order
                settings.sortingOrder = order.toSortingOrder()

                model?.reload()
            case .clear:
                guard availableActions.contains(.clear) else { break }
                model?.clear()
            case .reload:
                guard availableActions.contains(.reload) else { break }
                model?.reload()
            }
        }

        func setup(with model: PlainModelInterface, view: PresenterViewInterface) {
            self.modelCancellable?.cancel()
            self.modelCancellable = nil

            self.model = model
            self.view = view

            self.model?.sortingOrder = Model.SortingOrder(with: settings.sortingOrder)
            self.modelCancellable = self.model?.structureBind.bind { [weak self] structure in
                guard let self = self else { return }

                let newStucture = Presenter.emptyStructure + structure.compactMap { $0.toVisualItem() }
                DispatchQueue.main.async {
                #if USE_BINDING_FOR_PALIN_MVP
                    self.structureBind.value = newStucture
                    self.availableActionsBind.value = Self.availableActions(for: self.structureBind.value)
                #else
                    self.structure = newStucture
                    self.availableActions = Presenter.availableActions(for: newStucture)
                #endif // USE_BINDING_FOR_PALIN_MVP
                }
            }

            self.view?.presenter = self

            self.structure = Presenter.emptyStructure + self.model!.structure.compactMap { $0.toVisualItem() }
            self.availableActions = Presenter.availableActions(for: self.structure)
        }

        init(_ identifier: String? = nil) {
            guard let appCoordinator = UIApplication.shared.delegate as? AppCoordinator else {
                fatalError("Invalid app state")
            }

            let baseIdentifier = identifier ?? "com.mvp"

            settings = appCoordinator.settingsProvider(for: "\(baseIdentifier).settings")
            structure = Presenter.emptyStructure
        }

        private let settings: SettingsProviderInterface
        private var model: PlainModelInterface?
        private var modelCancellable: BindCancellable?
        private weak var view: PresenterViewInterface?
    }
}
