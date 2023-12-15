//
//  MVPPresenter.swift
//  Architectures
//
//  Created by developer on 15.12.2023.
//

import UIKit

extension Presenter {
    class MVP: PresenterInterface {
        private(set) var structure: [VisualItem]
        var sortingOrder: Model.SortingOrder { model.sortingOrder }
        private(set) var availableActions: Presenter.Actions = []

        init() {
            guard let appCoordinator = UIApplication.shared.delegate as? AppCoordinator else {
                fatalError("Invalid app state")
            }

            settings = appCoordinator.settingsProvider(for: "com.mvp.settings")

            model = Model.MVP(with: appCoordinator.dataProvider(for: "com.mvp.data"))
            model.sortingOrder = Model.SortingOrder(with: settings.sortingOrder)

            structure = model.structure.compactMap { $0.toVisualItem() }
        }

        private let settings: SettingsProviderInterface
        private let model: Model.MVP
    }
}
