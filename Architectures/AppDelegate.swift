//
//  AppDelegate.swift
//  Architectures
//
//  Created by developer on 06.12.2023.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }

    private var dataProviders = [String: DataProviderInterface]()
    private var settingsProviders = [String: SettingsProviderInterface]()
}

protocol AppCoordinator: AnyObject {
    func dataProvider(for identifier: String) -> DataProviderInterface
    func settingsProvider(for identifier: String) -> SettingsProviderInterface
}

extension AppDelegate: AppCoordinator {
    func dataProvider(for identifier: String) -> DataProviderInterface {
        if let provider = dataProviders[identifier] {
            return provider
        }

        let newProvider = ModelDataProvider(with: identifier)
        dataProviders[identifier] = newProvider

        return newProvider
    }

    func settingsProvider(for identifier: String) -> SettingsProviderInterface {
        if let provider = settingsProviders[identifier] {
            return provider
        }

        let newProvider = SettingsDataProvider(with: identifier)
        settingsProviders[identifier] = newProvider

        return newProvider
    }
}
