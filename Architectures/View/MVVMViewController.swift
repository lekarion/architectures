//
//  MVVMViewController.swift
//  Architectures
//
//  Created by developer on 08.12.2023.
//

import UIKit

protocol MVVMViewInterface: AnyObject {
    var clearButtonEnabled: Bool { get set }
    var reloadButtonEnabled: Bool { get set }
    var sortingOrderButtonEnabled: Bool { get set }

    var dataSource: MVVMViewDataSource? { get set }
    var delegate: MVVMViewDelegate? { get set }

    func reloadData()
}

protocol MVVMViewDataSource: AnyObject {
    func mvvmViewNumberOfItems(_ view: MVVMViewInterface) -> Int
    func mvvmView(_ view: MVVMViewInterface, itemAt index: Int) -> VisualItem
}

protocol MVVMViewDelegate: AnyObject {
    func mvvmView(_ view: MVVMViewInterface, sortingOrderDidChange: Model.SortingOrder)
    func mvvmViewDidRequestClear(_ view: MVVMViewInterface)
    func mvvmViewDidRequestReload(_ view: MVVMViewInterface)
}

// MARK: -
class MVVMViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let interface = children.first(where: { $0 is MVVMViewInterface }) as? MVVMViewInterface else {
            fatalError("No interface controller found")
        }

        viewInterface = interface
        viewInterface.dataSource = self
        viewInterface.delegate = self

        structureCancellable = viewModel.structure.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.viewInterface.reloadData()
            }
        }

        actionsCancellable = viewModel.availableActions.bind{ [weak self] actions in
            guard let self = self else { return }

            self.viewInterface.clearButtonEnabled = actions.contains(.clear)
            self.viewInterface.reloadButtonEnabled = actions.contains(.reload)
            self.viewInterface.sortingOrderButtonEnabled = actions.contains(.changeSortingOrder)
        }
    }

    private let viewModel = ViewModel.MVVM()
    private var structureCancellable: BindCancellable?
    private var actionsCancellable: BindCancellable?

    private weak var viewInterface: MVVMViewInterface!
}

extension MVVMViewController: MVVMViewDataSource {
    func mvvmViewNumberOfItems(_ view: MVVMViewInterface) -> Int {
        viewModel.structure.value.count
    }

    func mvvmView(_ view: MVVMViewInterface, itemAt index: Int) -> VisualItem {
        viewModel.structure.value[index]
    }
}

extension MVVMViewController: MVVMViewDelegate {
    func mvvmView(_ view: MVVMViewInterface, sortingOrderDidChange order: Model.SortingOrder) {
        viewModel.sortingOrder = order
    }

    func mvvmViewDidRequestClear(_ view: MVVMViewInterface) {
        viewModel.clearData()
    }

    func mvvmViewDidRequestReload(_ view: MVVMViewInterface) {
        viewModel.reloadData()
    }
}
