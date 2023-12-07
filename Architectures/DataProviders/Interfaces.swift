//
//  Interfaces.swift
//  Architectures
//
//  Created by developer on 07.12.2023.
//

import Foundation

protocol DataProviderInterface: AnyObject {
    var sortingOrder: SortingOrder { get set }
    func reload() -> [DataItemInterface]
}

protocol DataItemInterface {
    var iconName: String? { get }
    var title: String { get }
    var description: String? { get }
}

enum SortingOrder {
    case none, ascending, descending
}
