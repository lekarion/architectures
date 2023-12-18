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
    #if USE_COMBINE_FOR_VIEW_ACTIONS
        viewModel.setup(with: self)
    #else
        viewInterface.delegate = self
    #endif // USE_COMBINE_FOR_VIEW_ACTIONS

        viewModel.structureBind.receive(on: DispatchQueue.main).sink { [weak self] _ in
            self?.viewInterface.reloadData()
        }.store(in: &bag)

        viewModel.availableActionsBind.receive(on: DispatchQueue.main).map { $0.contains(.clear) }.assign(to: \.clearButtonEnabled, on: viewInterface).store(in: &bag)
        viewModel.availableActionsBind.receive(on: DispatchQueue.main).map { $0.contains(.reload) }.assign(to: \.reloadButtonEnabled, on: viewInterface).store(in: &bag)
        viewModel.availableActionsBind.receive(on: DispatchQueue.main).map { $0.contains(.changeSortingOrder) }.assign(to: \.sortingOrderButtonEnabled, on: viewInterface).store(in: &bag)

        viewModel.viewDidLoad()

        (viewInterface as? UIViewController)?.title = "MVVM + Combine"
        viewInterface.sortingOrder = viewModel.sortingOrder
    }

    private let viewModel = ViewModel.MVVMCombine()
    private var bag = Set<AnyCancellable>()

    private weak var viewInterface: ViewInterface!
}

extension MVVMCombineViewController: ViewDataSource {
    func viewControllerNumberOfItems(_ view: ViewInterface) -> Int {
        viewModel.structure.count
    }

    func viewController(_ view: ViewInterface, itemAt index: Int) -> VisualItem {
        viewModel.structure[index]
    }
}

#if USE_COMBINE_FOR_VIEW_ACTIONS
extension MVVMCombineViewController: ViewModelActionInterface {
    var actionEvent: AnyPublisher<ViewModelAction, Never> {
        viewInterface.actionEvent.map {
            let action: ViewModelAction
            switch $0 {
            case .chnageSortingOrder(let order):
                action = .changeSortingOrder(order: order)
            case .clear:
                action = .clear
            case .reload:
                action = .reload
            }

            return action
        }.eraseToAnyPublisher()
    }
}
#else
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
#endif // USE_COMBINE_FOR_VIEW_ACTIONS
