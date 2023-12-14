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
            safe(sync: true) { [weak self] in
                guard let readValue = self?.readValue(String.self, for: Keys.sortingOrder) else { return }
                guard let finalValue = SortingOrder(rawValue: readValue) else { return }
                result = finalValue
            }
            return result
        }

        set {
            safe { [weak self] in
                self?.writreValue(newValue.rawValue, for: Keys.sortingOrder)
            }
        }
    }

    private func safe(sync: Bool = false, handler: @escaping () -> Void) {
        let queue = DispatchQueue.main

        if sync {
            queue.sync { handler() }
        } else {
            queue.async { handler() }
        }
    }

    private let identifier: String
}

private extension SettingsDataProvider {
    func readValue<T>(_ type: T.Type, for key: String) -> T? {
        UserDefaults.standard.object(forKey: effectiveKey(for: key)) as? T
    }

    func writreValue<T>(_ value: T?, for key: String) {
        if let realValue = value {
            UserDefaults.standard.set(realValue, forKey: effectiveKey(for: key))
        } else {
            UserDefaults.standard.removeObject(forKey: effectiveKey(for: key))
        }
    }

    func effectiveKey(for key: String) -> String {
        return "\(identifier).\(key)"
    }

    struct Keys {
        static let sortingOrder = "sortingOrder"
    }
}
