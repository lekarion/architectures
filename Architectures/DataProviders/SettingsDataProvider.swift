//
//  SettingsDataProvider.swift
//  Architectures
//
//  Created by developer on 07.12.2023.
//

import Foundation

class SettingsDataProvider: SettingsProviderInterface {
    init(with identifier: String) {
        self.identifier = identifier
    }

    var sortingOrder: SortingOrder {
        get {
            var result: SortingOrder = .none
            safe(sync: true) { _ in
                result = UserDefaults.sortingOrder
            }
            return result
        }

        set {
            safe { _ in
                UserDefaults.sortingOrder = newValue
            }
        }
    }

    private func safe(sync: Bool = false, handler: @escaping (UserDefaults.Context) -> Void) {
        let context = UserDefaults.Context(identifier)
        let queue = DispatchQueue.main

        if sync {
            queue.sync { handler(context) }
        } else {
            queue.async { handler(context) }
        }
    }

    private let identifier: String
}
