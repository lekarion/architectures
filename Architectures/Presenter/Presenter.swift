//
//  Presenter.swift
//  Architectures
//
//  Created by developer on 15.12.2023.
//

import Foundation

protocol PresenterInterface: AnyObject {
    var structure: [VisualItem] { get }
    var sortingOrder: Model.SortingOrder { get }
    var availableActions: Presenter.Actions { get }

    func handle(action: Presenter.Action)
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
    }

    enum Update {
        case structure, availableActions
    }
}
