//
//  TableViewController.swift
//  Architectures
//
//  Created by developer on 18.12.2023.
//

import UIKit

class TableViewController: UITableViewController {
    static let plainMVPSegueIdentifier = "com.segue.plainMVP"
    static let combineMVPSegueIdentifier = "com.segue.combineMVP"

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Self.plainMVPSegueIdentifier:
            guard let view = segue.destination as? PresenterViewInterface else {
                fatalError("Invalid app state")
            }

            guard let appCoordinator = UIApplication.shared.delegate as? AppCoordinator else {
                fatalError("Invalid app state")
            }

            let providersIdentifier = "com.mvp.data"
            let model = Model.PlainModel(with: appCoordinator.dataProvider(for: providersIdentifier), imageProvider: appCoordinator.imagesProvider(for: providersIdentifier))
            let presenter = Presenter.MVP()

            presenter.setup(with: model, view: view)
        case Self.combineMVPSegueIdentifier:
            guard let view = segue.destination as? CombinePresenterViewInterface else {
                fatalError("Invalid app state")
            }

            guard let appCoordinator = UIApplication.shared.delegate as? AppCoordinator else {
                fatalError("Invalid app state")
            }

            let providersIdentifier = "com.mvp.combine.data"
            let model = Model.CombineModel(with: appCoordinator.dataProvider(for: providersIdentifier), imageProvider: appCoordinator.imagesProvider(for: providersIdentifier))
            let presenter = Presenter.MVPCombine()

            presenter.setup(with: model, view: view)
        default:
            break
        }
    }
}
