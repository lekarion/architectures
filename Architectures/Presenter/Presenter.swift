//
//  Presenter.swift
//  Architectures
//
//  Created by developer on 15.12.2023.
//

import Foundation

protocol PresenterInterface: AnyObject {
    var structure: [VisualItem] { get }
    var availableActions: Presenter.Actions { get }
    var sortingOrder: Model.SortingOrder { get }

    func handle(action: Presenter.Action)
    func validateForDuplication(_ items: [VisualItem]) -> Bool
}

protocol PresenterViewInterface: AnyObject {
    var presenter: PresenterInterface? { get set }
    func handle(update: Presenter.Update)
}

class Presenter {
    typealias Scheme = ViewModel.Scheme
    typealias Details = ViewModel.Details
    typealias Actions = ViewModel.Actions

    enum Action {
        case changeSortingOrder(order: Model.SortingOrder)
        case clear, reload
        case duplicate(items: [VisualItem])
    }

    enum Update {
        case structure, availableActions
    }
}

extension Presenter {
    static let emptyStructure = [Presenter.Scheme("Schemes/mvp-scheme")]
    static func availableActions(for structure: [VisualItem]) -> ViewModel.Actions {
        (emptyStructure.count == structure.count) ? .reload : .all
    }
}
