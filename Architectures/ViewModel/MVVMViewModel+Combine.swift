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
    var structureBind: AnyPublisher<[VisualItem], Never> { get }
    var availableActionsBind: AnyPublisher<ViewModel.Actions, Never> { get }
}

extension ViewModel {
    class MVVMCombine: MVVMViewModelCombineInterface {
        var structureBind: AnyPublisher<[VisualItem], Never> { structureSubject.eraseToAnyPublisher() }
        var availableActionsBind: AnyPublisher<ViewModel.Actions, Never> { availableActionsSubject.eraseToAnyPublisher() }

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
    #endif // USE_COMBINE_FOR_VIEW_ACTIONS

        func validateForDuplication(_ items: [VisualItem]) -> Bool {
            false
        }

        func duplicate(_ items: [VisualItem]) {
            // TODO: Implement
        }

        func viewDidLoad() {
            availableActionsSubject.send(Self.availableActions(for: structure))
        }

        init(_ identifier: String? = nil) {
            guard let appCoordinator = UIApplication.shared.delegate as? AppCoordinator else {
                fatalError("Invalid app state")
            }

            let baseIdentifier = identifier ?? "com.mvvm.combine"

            settings = appCoordinator.settingsProvider(for: "\(baseIdentifier).settings")

            let providersIdentifier = "\(baseIdentifier).data"
            model = Model.CombineModel(with: appCoordinator.dataProvider(for: providersIdentifier), imageProvider: appCoordinator.imagesProvider(for: providersIdentifier))
            model.sortingOrder = Model.SortingOrder(with: settings?.sortingOrder ?? .none)

            model.structureBind.receive(on: workQueue).sink { [weak self] value in
                guard let self = self else { return }

                let visualValue = value.compactMap({ $0.toVisualItem() })
                let newStructure = Self.emptyStructure + visualValue

                self.structure = newStructure
                self.structureSubject.send(newStructure)
                self.availableActionsSubject.send(Self.availableActions(for: newStructure))
            }.store(in: &bag)
        }

        deinit {
            bag.forEach { $0.cancel() }
        }

        private(set) var structure: [VisualItem] = emptyStructure
        private let structureSubject = PassthroughSubject<[VisualItem], Never>()
        private let availableActionsSubject = PassthroughSubject<ViewModel.Actions, Never>()

        private let settings: SettingsProviderInterface?
        private let model: Model.CombineModel
        private let workQueue = DispatchQueue(label: "com.developer.viewModelQueue", qos: .default)

        private var bag = Set<AnyCancellable>()
    }
}

private extension ViewModel.MVVMCombine {
    static let emptyStructure = [ViewModel.Scheme("Schemes/mvvm-scheme")]
    static func availableActions(for structure: [VisualItem]) -> ViewModel.Actions {
        (emptyStructure.count == structure.count) ? .reload : .all
    }
}
