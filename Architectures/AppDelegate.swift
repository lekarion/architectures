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

    func applicationDidEnterBackground(_ application: UIApplication) {
        startBackgroundTask()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        startBackgroundTask()
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }

    private var dataProviders = [String: DataProviderInterface]()
    private var settingsProviders = [String: SettingsProviderInterface]()
    private var imageProviders = [String: ImagesProviderInterface]()
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
}

protocol AppCoordinator: AnyObject {
    func dataProvider(for identifier: String) -> DataProviderInterface
    func settingsProvider(for identifier: String) -> SettingsProviderInterface
    func imagesProvider(for identifier: String) -> ImagesProviderInterface
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

    func imagesProvider(for identifier: String) -> ImagesProviderInterface {
        if let provider = imageProviders[identifier] {
            return provider
        }

        let newProvider = ImagesProvider(with: identifier, thumbnailSize: CGSize(width: 64.0, height: 64.0))
        imageProviders[identifier] = newProvider

        return newProvider
    }

    static let genericSettingsProviderId = "com.generic.settings"
}

private extension AppDelegate {
    func startBackgroundTask() {
        guard backgroundTask == .invalid else { return }

        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "com.architectures.backgroundTask") { [weak self] in
            guard let self = self else { return }

            dataProviders.forEach { (_, provider) in
                provider.flush()
            }

            UIApplication.shared.endBackgroundTask(self.backgroundTask)
            self.backgroundTask = .invalid
        }
    }
}
