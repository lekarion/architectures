//
//  MVPViewController+Combine.swift
//  Architectures
//
//  Created by developer on 18.12.2023.
//

import Combine
import UIKit

protocol CombinePresenterViewInterface: PresenterViewInterface {
    var actionEvent: AnyPublisher<Presenter.Action, Never> { get }
}

class MVPCombineViewController: UIViewController, CombinePresenterViewInterface {
    var presenter: PresenterInterface? {
        get { combinePresenter }
        set {
            guard nil != newValue else {
                combinePresenter = nil
                return
            }

            guard let value = newValue as? CombinePresenterInterface else { return }
            combinePresenter = value
        }
    }

    func handle(update: Presenter.Update) {
        fatalError("Not implemented")
    }

    var actionEvent: AnyPublisher<Presenter.Action, Never> { actionSubject.eraseToAnyPublisher() }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let interface = children.first(where: { $0 is ViewInterface }) as? ViewInterface else {
            fatalError("No interface controller found")
        }

        viewInterface = interface
        viewInterface.dataSource = self
        viewInterface.delegate = self

        combinePresenter?.structureBind.receive(on: DispatchQueue.main).sink { [weak self] _ in
            self?.viewInterface.reloadData()
        }.store(in: &bag)

        combinePresenter?.availableActionsBind.map { $0.contains(.clear) }.assign(to: \.clearButtonEnabled, on: viewInterface).store(in: &bag)
        combinePresenter?.availableActionsBind.map { $0.contains(.reload) }.assign(to: \.reloadButtonEnabled, on: viewInterface).store(in: &bag)
        combinePresenter?.availableActionsBind.map { $0.contains(.changeSortingOrder) }.assign(to: \.sortingOrderButtonEnabled, on: viewInterface).store(in: &bag)

        combinePresenter?.viewDidLoad()

        (viewInterface as? UIViewController)?.title = "MVP + Combine"
        viewInterface.sortingOrder = combinePresenter?.sortingOrder ?? .none
    }

    private var combinePresenter: CombinePresenterInterface?
    private weak var viewInterface: ViewInterface!
    private let actionSubject = PassthroughSubject<Presenter.Action, Never>()

    private var bag = Set<AnyCancellable>()
}

extension MVPCombineViewController: ViewDataSource {
    func viewControllerNumberOfItems(_ view: ViewInterface) -> Int {
        combinePresenter?.structure.count ?? 0
    }

    func viewController(_ view: ViewInterface, itemAt index: Int) -> VisualItem {
        guard let presenter = self.combinePresenter else {
            fatalError("Invalid internal state")
        }
        return presenter.structure[index]
    }
}

extension MVPCombineViewController: ViewDelegate {
    func viewController(_ view: ViewInterface, sortingOrderDidChange order: Model.SortingOrder) {
        actionSubject.send(.changeSortingOrder(order: order))
    }

    func viewControllerDidRequestClear(_ view: ViewInterface) {
        actionSubject.send(.reset)
        actionSubject.send(.clear)
    }

    func viewControllerDidRequestReload(_ view: ViewInterface) {
        actionSubject.send(.reload)
    }

    func viewController(_ view: ViewInterface, isDuplicationAvailableFor item: VisualItem) -> Bool {
        combinePresenter?.validateForDuplication([item]) ?? false
    }

    func viewController(_ view: ViewInterface, didRequestDuplicate item: VisualItem) {
        actionSubject.send(.duplicate(items: [item]))
    }
}
