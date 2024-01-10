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

    func viewDidLoad()
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

        func validateForDuplication(_ items: [VisualItem]) -> Bool {
            guard let model = self.model else { return false }
            return !model.validateForDuplication(items.compactMap({ $0.toModelItem() })).isEmpty
        }

        var structureBind: AnyPublisher<[VisualItem], Never> { structureSubject.eraseToAnyPublisher() }
        var availableActionsBind: AnyPublisher<Presenter.Actions, Never> { availableActionsSubject.eraseToAnyPublisher() }

        func viewDidLoad() {
            structureSubject.send(structure)
            availableActionsSubject.send(availableActions)
        }

        func setup(with model: CombineModelInterface, view: CombinePresenterViewInterface) {
            self.bag.removeAll()

            self.model = model
            self.view = view

            self.model?.sortingOrder = Model.SortingOrder(with: settings.sortingOrder)
            self.model?.structureBind.receive(on: DispatchQueue.main).sink { [weak self] structure in
                guard let self = self else { return }

                let newStucture = Presenter.emptyStructure + structure.compactMap { $0.toVisualItem() }
                self.structure = newStucture
                self.availableActions = Presenter.availableActions(for: newStucture)
            }.store(in: &bag)

            self.view?.presenter = self
            self.view?.actionEvent.sink { [weak self] in
                guard let self = self else { return }

                switch $0 {
                case .changeSortingOrder(let order):
                    guard self.availableActions.contains(.changeSortingOrder) else { break }

                    self.sortingOrder = order
                    self.settings.sortingOrder = order.toSortingOrder()

                    self.model?.reload()
                case .clear:
                    guard self.availableActions.contains(.clear) else { break }
                    self.model?.clear()
                case .reset:
                    guard self.availableActions.contains(.clear) else { break }
                    self.model?.reset()
                case .reload:
                    guard self.availableActions.contains(.reload) else { break }
                    self.model?.reload()
                case .duplicate(let items):
                    guard let validItems = self.model?.validateForDuplication(items.compactMap({ $0.toModelItem() })), !validItems.isEmpty else { return }
                    self.model?.duplicate(validItems)
                }
            }.store(in: &bag)

            self.structure = Presenter.emptyStructure + self.model!.structure.compactMap { $0.toVisualItem() }
            self.availableActions = Presenter.availableActions(for: self.structure)
        }

        init(_ identifier: String? = nil) {
            guard let appCoordinator = UIApplication.shared.delegate as? AppCoordinator else {
                fatalError("Invalid app state")
            }

            let baseIdentifier = identifier ?? "com.mvp.combine"

            settings = appCoordinator.settingsProvider(for: "\(baseIdentifier).settings")
            structure = Presenter.emptyStructure
        }

        private let settings: SettingsProviderInterface
        private var model: CombineModelInterface?
        private weak var view: CombinePresenterViewInterface?

        private var bag = Set<AnyCancellable>()

        private let structureSubject = PassthroughSubject<[VisualItem], Never>()
        private let availableActionsSubject = PassthroughSubject<Presenter.Actions, Never>()
    }
}
