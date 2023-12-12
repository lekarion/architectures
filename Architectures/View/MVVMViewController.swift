//
//  MVVMViewController.swift
//  Architectures
//
//  Created by developer on 08.12.2023.
//

#if USE_COMBINE_FOR_VIEW_ACTIONS
import Combine
#endif // USE_COMBINE_FOR_VIEW_ACTIONS
import UIKit

class MVVMViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let interface = children.first(where: { $0 is ViewInterface }) as? ViewInterface else {
            fatalError("No interface controller found")
        }

        viewInterface = interface
        viewInterface.dataSource = self

    #if USE_COMBINE_FOR_VIEW_ACTIONS
        viewInterface.actionEvent.sink { [weak self] in
            switch $0 {
            case .chnageSortingOrder(let order):
                self?.viewModel.sortingOrder = order
            case .clear:
                self?.viewModel.clearData()
            case .reload:
                self?.viewModel.reloadData()
            }
        }.store(in: &bag)
    #else
        viewInterface.delegate = self
    #endif // USE_COMBINE_FOR_VIEW_ACTIONS

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

        viewInterface.clearButtonEnabled = viewModel.availableActions.value.contains(.clear)
        viewInterface.reloadButtonEnabled = viewModel.availableActions.value.contains(.reload)
        viewInterface.sortingOrderButtonEnabled = viewModel.availableActions.value.contains(.changeSortingOrder)

        (viewInterface as? UIViewController)?.title = "MVVM"
    }

    private let viewModel = ViewModel.MVVM()
    private var structureCancellable: BindCancellable?
    private var actionsCancellable: BindCancellable?

    private weak var viewInterface: ViewInterface!
#if USE_COMBINE_FOR_VIEW_ACTIONS
    private var bag = Set<AnyCancellable>()
#endif // USE_COMBINE_FOR_VIEW_ACTIONS
}

extension MVVMViewController: ViewDataSource {
    func viewControllerNumberOfItems(_ view: ViewInterface) -> Int {
        viewModel.structure.value.count
    }

    func viewControler(_ view: ViewInterface, itemAt index: Int) -> VisualItem {
        viewModel.structure.value[index]
    }
}

#if USE_COMBINE_FOR_VIEW_ACTIONS
#else
extension MVVMViewController: ViewDelegate {
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
