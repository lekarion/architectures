//
//  MVVMViewController+Combine.swift
//  Architectures
//
//  Created by developer on 11.12.2023.
//

import Combine
import UIKit

class MVVMCombineViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let interface = children.first(where: { $0 is ViewInterface }) as? ViewInterface else {
            fatalError("No interface controller found")
        }

        viewInterface = interface
        viewInterface.dataSource = self
        viewInterface.delegate = self

        viewModel.structure.receive(on: DispatchQueue.main).sink { [weak self] _ in
            self?.viewInterface.reloadData()
        }.store(in: &bag)

        viewModel.availableActions.receive(on: DispatchQueue.main).map { $0.contains(.clear) }.assign(to: \.clearButtonEnabled, on: viewInterface).store(in: &bag)
        viewModel.availableActions.receive(on: DispatchQueue.main).map { $0.contains(.reload) }.assign(to: \.reloadButtonEnabled, on: viewInterface).store(in: &bag)
        viewModel.availableActions.receive(on: DispatchQueue.main).map { $0.contains(.changeSortingOrder) }.assign(to: \.sortingOrderButtonEnabled, on: viewInterface).store(in: &bag)

        (viewInterface as? UIViewController)?.title = "MVVM + Combine"
    }

    private let viewModel = ViewModel.MVVMCombine()
    private var bag = Set<AnyCancellable>()

    private weak var viewInterface: ViewInterface!
}

extension MVVMCombineViewController: ViewDataSource {
    func viewControllerNumberOfItems(_ view: ViewInterface) -> Int {
        viewModel.structure.value.count
    }

    func viewControler(_ view: ViewInterface, itemAt index: Int) -> VisualItem {
        viewModel.structure.value[index]
    }
}

extension MVVMCombineViewController: ViewDelegate {
    func viewController(_ view: ViewInterface, sortingOrderDidChange order: Model.SortingOrder) {
        viewModel.sortingOrder = order
    }

    func viewControllerDidRequestClear(_ view: ViewInterface) {
        viewModel.clearData()
    }

    func viewControllerDidRequestReload(_ view: ViewInterface) {
        viewModel.reloadData()
    }
}
