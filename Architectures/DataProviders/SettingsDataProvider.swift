//
//  SettingsDataProvider.swift
//  Architectures
//
//  Created by developer on 07.12.2023.
//

import Foundation
import UIKit.UIColor

class SettingsDataProvider: SettingsProviderInterface {
    init(with identifier: String) {
        self.identifier = identifier
    }

    var sortingOrder: SortingOrder {
        get { readValue(SortingOrder.self, for: Keys.sortingOrder) ?? .none }
        set { writeValue(newValue, for: Keys.sortingOrder) }
    }

    var presentationInAnimationDirection: PresentationAnimationDirection? {
        get { readValue(SDTPresentationAnimationDirection.self, for: Keys.presentationInAnimationDirection)?.toPresentationAnimationDirection() }
        set { writeValue((nil != newValue) ? SDTPresentationAnimationDirection(newValue.unsafelyUnwrapped) : nil, for: Keys.presentationInAnimationDirection) }
    }

    var presentationOutAnimationDirection: PresentationAnimationDirection? {
        get { readValue(SDTPresentationAnimationDirection.self, for: Keys.presentationOutAnimationDirection)?.toPresentationAnimationDirection() }
        set { writeValue((nil != newValue) ? SDTPresentationAnimationDirection(newValue.unsafelyUnwrapped) : nil, for: Keys.presentationOutAnimationDirection) }
    }

    var presentationDimmingColor: UIColor? {
        get { readValue(UIColor.self, for: Keys.presentationDimmingColor) }
        set { writeValue(newValue, for: Keys.presentationDimmingColor) }
    }

    // MARK: ### Private ###
    private func safe(sync: Bool = false, handler: @escaping () -> Void) {
        if sync {
            workQueue.sync { handler() }
        } else {
            workQueue.async { handler() }
        }
    }

    private let identifier: String
    private let workQueue = DispatchQueue(label: "com.settingsDataProvider.queue", qos: .utility)
}

// MARK: -
private extension SettingsDataProvider {
    func readValue<T>(_ type: T.Type, for key: String) -> T? {
        var result: T? = nil
        safe(sync: true) { [weak self] in
            guard let self = self else { return }
            result = UserDefaults.standard.object(forKey: self.effectiveKey(for: key)) as? T
        }
        return result
    }

    func readValue<T: RawRepresentable>(_ type: T.Type, for key: String) -> T? {
        var result: T? = nil
        safe(sync: true) { [weak self] in
            guard let self = self else { return }
            guard let objValue = UserDefaults.standard.object(forKey: self.effectiveKey(for: key)) as? T.RawValue else { return }
            result = T(rawValue: objValue)
        }
        return result
    }

    func readValue<T: Decodable>(_ type: T.Type, for key: String) -> T? {
        var result: T? = nil
        safe(sync: true) { [weak self] in
            guard let self = self else { return }
            guard let objValue = UserDefaults.standard.data(forKey: self.effectiveKey(for: key)) else { return }
            result = try? JSONDecoder().decode(T.self, from: objValue) as T
        }
        return result
    }

    func readValue<T>(_ type: T.Type, for key: String) -> T? where T : NSSecureCoding, T : NSObject {
        var result: T? = nil
        safe(sync: true) { [weak self] in
            guard let self = self else { return }
            guard let objValue = UserDefaults.standard.data(forKey: self.effectiveKey(for: key)) else { return }
            result = try? NSKeyedUnarchiver.unarchivedObject(ofClass: T.self, from: objValue)
        }
        return result
    }

    func writeValue<T: RawRepresentable>(_ value: T?, for key: String) {
        safe { [weak self] in
            guard let self = self else { return }

            if let realValue = value {
                UserDefaults.standard.set(realValue.rawValue, forKey: self.effectiveKey(for: key))
            } else {
                UserDefaults.standard.removeObject(forKey: self.effectiveKey(for: key))
            }
        }
    }

    func writeValue<T: Encodable>(_ value: T?, for key: String) {
        safe { [weak self] in
            guard let self = self else { return }

            if let realValue = value, let data = try? JSONEncoder().encode(realValue) {
                UserDefaults.standard.set(data, forKey: self.effectiveKey(for: key))
            } else {
                UserDefaults.standard.removeObject(forKey: self.effectiveKey(for: key))
            }
        }
    }

    func writeValue<T: NSSecureCoding>(_ value: T?, for key: String) {
        safe { [weak self] in
            guard let self = self else { return }

            if let realValue = value {
                UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: realValue), forKey: self.effectiveKey(for: key))
            } else {
                UserDefaults.standard.removeObject(forKey: self.effectiveKey(for: key))
            }
        }
    }

    func effectiveKey(for key: String) -> String {
        return "\(identifier).\(key)"
    }

    struct Keys {
        static let sortingOrder = "sortingOrder"
        static let presentationInAnimationDirection = "presentationInAnimationDirection"
        static let presentationOutAnimationDirection = "presentationOutAnimationDirection"
        static let presentationDimmingColor = "presentationDimmingColor"
    }
}
