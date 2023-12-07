//
//  UserDefaults+Settings.swift
//  Architectures
//
//  Created by developer on 07.12.2023.
//

import Foundation

protocol AnyOptional {
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    public var isNil: Bool { self == nil }
}

@propertyWrapper
struct UserDefault<Value> {
    let key: String
    let defaultValue: Value
    var defaults: UserDefaults = .standard

    var wrappedValue: Value {
        get {
            defaults.object(forKey: key) as? Value ?? defaultValue
        }
        set {
            if let opt = newValue as? AnyOptional, opt.isNil {
                defaults.removeObject(forKey: key)
            } else {
                defaults.set(newValue, forKey: key)
            }
        }
    }

    private static func effectiveKey(for key: String) -> String {
        guard let identifier = UserDefaults.defaultsContext?.identifier else { return key }
        return "\(identifier).\(key)"
    }
}

extension UserDefaults {
    private struct Keys {
        static let sortingOrder = "sortingOrder"
    }

    @UserDefault(key: Keys.sortingOrder, defaultValue: .none)
    static var sortingOrder: SortingOrder
}

extension UserDefaults {
    class Context {
        init(_ identifier: String) {
            self.identifier = identifier
            UserDefaults.defaultsContext = self
        }

        deinit {
            if UserDefaults.defaultsContext === self {
                UserDefaults.defaultsContext = nil
            }
        }

        let identifier: String
    }

    private(set) static var defaultsContext: Context?
}
