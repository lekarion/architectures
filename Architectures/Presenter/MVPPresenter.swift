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
                sortingOrder = order
            case .clear:
                model?.clear()
            case .reload:
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

                let newStucture = Self.emptyStructure + structure.compactMap { $0.toVisualItem() }
                DispatchQueue.main.async {
                #if USE_BINDING_FOR_PALIN_MVP
                    self.structureBind.value = newStucture
                    self.availableActionsBind.value = Self.availableActions(for: self.structureBind.value)
                #else
                    self.structure = newStucture
                    self.availableActions = Self.availableActions(for: newStucture)
                #endif // USE_BINDING_FOR_PALIN_MVP
                }
            }

            self.view?.presenter = self

            self.structure = Self.emptyStructure + self.model!.structure.compactMap { $0.toVisualItem() }
        }

        init(_ identifier: String? = nil) {
            guard let appCoordinator = UIApplication.shared.delegate as? AppCoordinator else {
                fatalError("Invalid app state")
            }

            let baseIdentifier = identifier ?? "com.mvp"

            settings = appCoordinator.settingsProvider(for: "\(baseIdentifier).settings")
            structure = Self.emptyStructure
        }

        private let settings: SettingsProviderInterface
        private var model: PlainModelInterface?
        private var modelCancellable: BindCancellable?
        private weak var view: PresenterViewInterface?
    }
}

private extension Presenter.MVP {
    static let emptyStructure = [Presenter.Scheme("Schemes/mvp-scheme")]
    static func availableActions(for structure: [VisualItem]) -> ViewModel.Actions {
        (emptyStructure.count == structure.count) ? .reload : .all
    }
}
