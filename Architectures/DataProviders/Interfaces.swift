//
//  Interfaces.swift
//  Architectures
//
//  Created by developer on 07.12.2023.
//

import Foundation

// MARK: - ### Data provider ### -
protocol DataProviderInterface: AnyObject {
    var sortingOrder: SortingOrder { get set }

    func reload() -> [DataItemInterface]
    func merge(_ items: [DataItemInterface])
    func flush()
}

protocol DataItemInterface {
    var iconName: String? { get }
    var title: String { get }
    var description: String? { get }
}

// MARK: - ### Settings provider ### -

protocol SettingsProviderInterface: AnyObject {
    var sortingOrder: SortingOrder { get set }
}

// MARK: -
enum SortingOrder: String {
    case none, ascending, descending
}
