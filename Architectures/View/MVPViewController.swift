//
//  MVPViewController.swift
//  Architectures
//
//  Created by developer on 18.12.2023.
//

import UIKit

class MVPViewController: UIViewController, PresenterViewInterface {
    var presenter: PresenterInterface?

    func handle(update: Presenter.Update) {
        guard let interface = self.viewInterface else { return }

        switch update {
        case .structure:
            interface.reloadData()
        case .availableActions:
            interface.clearButtonEnabled = presenter?.availableActions.contains(.clear) ?? false
            interface.reloadButtonEnabled = presenter?.availableActions.contains(.reload) ?? false
            interface.sortingOrderButtonEnabled = presenter?.availableActions.contains(.changeSortingOrder) ?? false
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let interface = children.first(where: { $0 is ViewInterface }) as? ViewInterface else {
            fatalError("No interface controller found")
        }

        viewInterface = interface
        viewInterface?.dataSource = self
        viewInterface?.delegate = self

        viewInterface?.clearButtonEnabled = presenter?.availableActions.contains(.clear) ?? false
        viewInterface?.reloadButtonEnabled = presenter?.availableActions.contains(.reload) ?? false
        viewInterface?.sortingOrderButtonEnabled = presenter?.availableActions.contains(.changeSortingOrder) ?? false

        (viewInterface as? UIViewController)?.title = "MVP"
        viewInterface?.sortingOrder = presenter?.sortingOrder ?? .none
    }

    private weak var viewInterface: ViewInterface?
}

extension MVPViewController: ViewDataSource {
    func viewControllerNumberOfItems(_ view: ViewInterface) -> Int {
        presenter?.structure.count ?? 0
    }

    func viewController(_ view: ViewInterface, itemAt index: Int) -> VisualItem {
        guard let presenter = self.presenter else {
            fatalError("Invalid internal state")
        }
        return presenter.structure[index]
    }
}

extension MVPViewController: ViewDelegate {
    func viewController(_ view: ViewInterface, sortingOrderDidChange order: Model.SortingOrder) {
        presenter?.handle(action: .changeSortingOrder(order: order))
    }

    func viewControllerDidRequestClear(_ view: ViewInterface) {
        presenter?.handle(action: .clear)
    }

    func viewControllerDidRequestReload(_ view: ViewInterface) {
        presenter?.handle(action: .reload)
    }
}
