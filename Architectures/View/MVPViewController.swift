//
//  MVPViewController.swift
//  Architectures
//
//  Created by developer on 18.12.2023.
//

import UIKit

class MVPViewController: UIViewController, PresenterViewInterface {
#if USE_BINDING_FOR_PALIN_MVP
    var presenter: PresenterInterface? {
        didSet {
            structureCancellable?.cancel()
            actionsCancellable?.cancel()

            guard let painPresenter = presenter as? PlainPresenterInterface else { return }

            setupBindings(painPresenter)
        }
    }

    func handle(update: Presenter.Update) {
        fatalError("Not implemented")
    }
#else
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
#endif // USE_BINDING_FOR_PALIN_MVP

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let interface = children.first(where: { $0 is ViewInterface }) as? ViewInterface else {
            fatalError("No interface controller found")
        }

        viewInterface = interface
        viewInterface?.dataSource = self
    #if USE_COMBINE_FOR_VIEW_ACTIONS
    #else
        viewInterface?.delegate = self
    #endif // USE_COMBINE_FOR_VIEW_ACTIONS

        viewInterface?.clearButtonEnabled = presenter?.availableActions.contains(.clear) ?? false
        viewInterface?.reloadButtonEnabled = presenter?.availableActions.contains(.reload) ?? false
        viewInterface?.sortingOrderButtonEnabled = presenter?.availableActions.contains(.changeSortingOrder) ?? false

        (viewInterface as? UIViewController)?.title = "MVP"
        viewInterface?.sortingOrder = presenter?.sortingOrder ?? .none
    }

#if USE_BINDING_FOR_PALIN_MVP
    private func setupBindings(_ painPresenter: PlainPresenterInterface) {
        structureCancellable = painPresenter.structureBind.bind { [weak self] _ in
            guard let interface = self?.viewInterface else { return }
            interface.reloadData()
        }

        actionsCancellable = painPresenter.availableActionsBind.bind { [weak self] in
            guard let interface = self?.viewInterface else { return }

            interface.clearButtonEnabled = $0.contains(.clear)
            interface.reloadButtonEnabled = $0.contains(.reload)
            interface.sortingOrderButtonEnabled = $0.contains(.changeSortingOrder)
        }
    }

    var structureCancellable: BindCancellable?
    var actionsCancellable: BindCancellable?
#endif // USE_BINDING_FOR_PALIN_MVP

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

    func viewController(_ view: ViewInterface, isDuplicationAvailableFor item: VisualItem) -> Bool {
        presenter?.validateForDuplication([item]) ?? false
    }
}

#if USE_COMBINE_FOR_VIEW_ACTIONS
#else
extension MVPViewController: ViewDelegate {
    func viewController(_ view: ViewInterface, sortingOrderDidChange order: Model.SortingOrder) {
        presenter?.handle(action: .changeSortingOrder(order: order))
    }

    func viewControllerDidRequestClear(_ view: ViewInterface) {
        presenter?.handle(action: .reset)
        presenter?.handle(action: .clear)
    }

    func viewControllerDidRequestReload(_ view: ViewInterface) {
        presenter?.handle(action: .reload)
    }

    func viewController(_ view: ViewInterface, didRequestDuplicate item: VisualItem) {
        presenter?.handle(action: .duplicate(items: [item]))
    }
}
#endif // USE_COMBINE_FOR_VIEW_ACTIONS
