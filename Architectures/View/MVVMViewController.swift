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
        viewModel.setup(with: self)
    #else
        viewInterface.delegate = self
    #endif // USE_COMBINE_FOR_VIEW_ACTIONS

        structureCancellable = viewModel.structureBind.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.viewInterface.reloadData()
            }
        }

        actionsCancellable = viewModel.availableActionsBind.bind{ [weak self] actions in
            guard let self = self else { return }

            self.viewInterface.clearButtonEnabled = actions.contains(.clear)
            self.viewInterface.reloadButtonEnabled = actions.contains(.reload)
            self.viewInterface.sortingOrderButtonEnabled = actions.contains(.changeSortingOrder)
        }

        viewInterface.clearButtonEnabled = viewModel.availableActionsBind.value.contains(.clear)
        viewInterface.reloadButtonEnabled = viewModel.availableActionsBind.value.contains(.reload)
        viewInterface.sortingOrderButtonEnabled = viewModel.availableActionsBind.value.contains(.changeSortingOrder)

        (viewInterface as? UIViewController)?.title = "MVVM"
        viewInterface.sortingOrder = viewModel.sortingOrder
    }

    private let viewModel = ViewModel.MVVM()
    private var structureCancellable: BindCancellable?
    private var actionsCancellable: BindCancellable?

    private weak var viewInterface: ViewInterface!
}

extension MVVMViewController: ViewDataSource {
    func viewControllerNumberOfItems(_ view: ViewInterface) -> Int {
        viewModel.structure.count
    }

    func viewController(_ view: ViewInterface, itemAt index: Int) -> VisualItem {
        viewModel.structure[index]
    }

    func viewController(_ view: ViewInterface, isDuplicationAvailableFor item: VisualItem) -> Bool {
        viewModel.validateForDuplication([item])
    }
}

#if USE_COMBINE_FOR_VIEW_ACTIONS
extension MVVMViewController: ViewModelActionInterface {
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
            case .duplicate(let item):
                action = .duplicate(items: [item])
            }

            return action
        }.eraseToAnyPublisher()
    }
}
#else
extension MVVMViewController: ViewDelegate {
    func viewController(_ view: ViewInterface, sortingOrderDidChange order: Model.SortingOrder) {
        viewModel.sortingOrder = order
    }

    func viewControllerDidRequestClear(_ view: ViewInterface) {
        viewModel.resetData()
        viewModel.clearData()
    }

    func viewControllerDidRequestReload(_ view: ViewInterface) {
        viewModel.reloadData()
    }

    
    func viewController(_ view: ViewInterface, didRequestDuplicate item: VisualItem) {
        viewModel.duplicate([item])
    }
}
#endif // USE_COMBINE_FOR_VIEW_ACTIONS
