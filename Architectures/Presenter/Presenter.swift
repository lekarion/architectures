//
//  Presenter.swift
//  Architectures
//
//  Created by developer on 15.12.2023.
//

import Foundation

protocol PresenterInterface: AnyObject { // presenter view input interface
    var structure: [VisualItem] { get }
    var sortingOrder: Model.SortingOrder { get }
    var availableActions: Presenter.Actions { get }
}

protocol PresenterViewInterface: AnyObject { // presenter view output interface
    func sortingOrderChanged(to order: Model.SortingOrder)
    func reloadDataRequested()
    func clearDataRequested()
}

class Presenter {
    typealias Scheme = ViewModel.Scheme
    typealias Details = ViewModel.Details
    typealias Actions = ViewModel.Actions 
}
