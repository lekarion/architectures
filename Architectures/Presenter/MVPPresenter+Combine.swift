//
//  MVPPresenter+Combine.swift
//  Architectures
//
//  Created by developer on 15.12.2023.
//

import Combine
import UIKit

protocol CombinePresenterInterface: PresenterInterface {
    var structureBind: AnyPublisher<[VisualItem], Never> { get }
    var availableActionsBind: AnyPublisher<Presenter.Actions, Never> { get }
}

extension Presenter {
    class MVPCombine: CombinePresenterInterface {
        private(set) var structure: [VisualItem] {
            didSet {
                structureSubject.send(structure)
            }
        }

        private(set) var sortingOrder: Model.SortingOrder {
            get { model?.sortingOrder ?? .none }
            set { model?.sortingOrder = newValue }
        }

        private(set) var availableActions: Presenter.Actions = [] {
            didSet {
                availableActionsSubject.send(availableActions)
            }
        }

        func handle(action: Presenter.Action) {
            fatalError("Not implemented")
        }

        var structureBind: AnyPublisher<[VisualItem], Never> { structureSubject.eraseToAnyPublisher() }
        var availableActionsBind: AnyPublisher<Presenter.Actions, Never> { availableActionsSubject.eraseToAnyPublisher() }

        func setup(with model: CombineModelInterface, view: CombinePresenterViewInterface) {
            self.bag.removeAll()

            self.model = model
            self.view = view

            self.model?.sortingOrder = Model.SortingOrder(with: settings.sortingOrder)
            self.model?.structureBind.receive(on: DispatchQueue.main).sink { [weak self] structure in
                guard let self = self else { return }

                let newStucture = Self.emptyStructure + structure.compactMap { $0.toVisualItem() }
            #if USE_BINDING_FOR_PALIN_MVP
                self.structureBind.value = newStucture
                self.availableActionsBind.value = Self.availableActions(for: self.structureBind.value)
            #else
                self.structure = newStucture
                self.availableActions = Self.availableActions(for: newStucture)
            #endif // USE_BINDING_FOR_PALIN_MVP
            }.store(in: &bag)

            self.view?.presenter = self

            self.structure = Self.emptyStructure + self.model!.structure.compactMap { $0.toVisualItem() }
            self.availableActions = Self.availableActions(for: self.structure)
        }

        init(_ identifier: String? = nil) {
            guard let appCoordinator = UIApplication.shared.delegate as? AppCoordinator else {
                fatalError("Invalid app state")
            }

            let baseIdentifier = identifier ?? "com.mvp.combine"

            settings = appCoordinator.settingsProvider(for: "\(baseIdentifier).settings")
            structure = Self.emptyStructure
        }

        private let settings: SettingsProviderInterface
        private var model: CombineModelInterface?
        private weak var view: CombinePresenterViewInterface?

        private var bag = Set<AnyCancellable>()

        private let structureSubject = PassthroughSubject<[VisualItem], Never>()
        private let availableActionsSubject = PassthroughSubject<Presenter.Actions, Never>()
    }
}

private extension Presenter.MVPCombine {
    static let emptyStructure = [Presenter.Scheme("Schemes/mvp-scheme")]
    static func availableActions(for structure: [VisualItem]) -> ViewModel.Actions {
        (emptyStructure.count == structure.count) ? .reload : .all
    }
}
