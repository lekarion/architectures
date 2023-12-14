//
//  ViewController.swift
//  Architectures
//
//  Created by developer on 08.12.2023.
//

#if USE_COMBINE_FOR_VIEW_ACTIONS
import Combine
#endif // USE_COMBINE_FOR_VIEW_ACTIONS
import UIKit

protocol ViewInterface: AnyObject {
    var clearButtonEnabled: Bool { get set }
    var reloadButtonEnabled: Bool { get set }
    var sortingOrderButtonEnabled: Bool { get set }

    var sortingOrder: Model.SortingOrder { get set }
    var dataSource: ViewDataSource? { get set }
#if USE_COMBINE_FOR_VIEW_ACTIONS
    var actionEvent: AnyPublisher<ViewActions, Never> { get }
#else
    var delegate: ViewDelegate? { get set }
#endif // USE_COMBINE_FOR_VIEW_ACTIONS

    func reloadData()
}

protocol ViewDataSource: AnyObject {
    func viewControllerNumberOfItems(_ view: ViewInterface) -> Int
    func viewControler(_ view: ViewInterface, itemAt index: Int) -> VisualItem
}
#if USE_COMBINE_FOR_VIEW_ACTIONS
enum ViewActions {
    case chnageSortingOrder(order: Model.SortingOrder)
    case clear, reload
}
#else
protocol ViewDelegate: AnyObject {
    func viewController(_ view: ViewInterface, sortingOrderDidChange: Model.SortingOrder)
    func viewControllerDidRequestClear(_ view: ViewInterface)
    func viewControllerDidRequestReload(_ view: ViewInterface)
}
#endif // USE_COMBINE_FOR_VIEW_ACTIONS

class ViewController: UIViewController, ViewInterface {
    weak var dataSource: ViewDataSource?
#if USE_COMBINE_FOR_VIEW_ACTIONS
    var actionEvent: AnyPublisher<ViewActions, Never> { actionSubject.eraseToAnyPublisher() }
#else
    weak var delegate: ViewDelegate?
#endif // USE_COMBINE_FOR_VIEW_ACTIONS

    var clearButtonEnabled: Bool {
        get { clearButton.isEnabled }
        set { clearButton.isEnabled = newValue }
    }
    var reloadButtonEnabled: Bool {
        get { reloadButton.isEnabled }
        set { reloadButton.isEnabled = newValue }
    }
    var sortingOrderButtonEnabled: Bool {
        get { sortingButton.isEnabled }
        set { sortingButton.isEnabled = newValue }
    }

    var sortingOrder: Model.SortingOrder = .none {
        didSet {
            sortingButton.setTitle(sortingOrder.toString(), for: .normal)
            sortingButton.setImage(sortingOrder.toImage(), for: .normal)
        }
    }

    func reloadData() {
        dataViewController.reloadData()
    }

    override var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let dataViewController = children.first(where: { $0 is DataViewControllerInterface }) as? DataViewControllerInterface else {
            fatalError("No data controller found")
        }

        self.dataViewController = dataViewController
        self.dataViewController.dataSource = self

        let sortingMenu = UIMenu(title: "Sorting in", options: .displayInline, children: Model.SortingOrder.allCases.map({ order in
            UIAction(title: order.toString(), image: order.toImage(), handler: { [weak self] in
                guard let self = self else { return }

            #if USE_COMBINE_FOR_VIEW_ACTIONS
                self.actionSubject.send(.chnageSortingOrder(order: order))
            #else
                self.delegate?.viewController(self, sortingOrderDidChange: order)
            #endif // USE_COMBINE_FOR_VIEW_ACTIONS
                self.sortingButton.setTitle($0.title, for: .normal)
                self.sortingButton.setImage($0.image, for: .normal)
            })
        }))

        sortingButton.menu = sortingMenu
        sortingButton.showsMenuAsPrimaryAction = true

        sortingButton.setTitle(sortingOrder.toString(), for: .normal)
        sortingButton.setImage(sortingOrder.toImage(), for: .normal)
    }

    @IBOutlet private weak var clearButton: UIButton!
    @IBOutlet private weak var sortingButton: UIButton!
    @IBOutlet private weak var reloadButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!

    private var dataViewController: DataViewControllerInterface!
#if USE_COMBINE_FOR_VIEW_ACTIONS
    private var actionSubject = PassthroughSubject<ViewActions, Never>()
#endif // USE_COMBINE_FOR_VIEW_ACTIONS
}

extension ViewController { // Actions
    @IBAction func onReloadButton(_ sender: UIButton) {
    #if USE_COMBINE_FOR_VIEW_ACTIONS
        actionSubject.send(.reload)
    #else
        delegate?.viewControllerDidRequestReload(self)
    #endif // USE_COMBINE_FOR_VIEW_ACTIONS
    }

    @IBAction func onClearButton(_ sender: UIButton) {
    #if USE_COMBINE_FOR_VIEW_ACTIONS
        actionSubject.send(.clear)
    #else
        delegate?.viewControllerDidRequestClear(self)
    #endif // USE_COMBINE_FOR_VIEW_ACTIONS
    }
}

extension ViewController: DataTableViewControllerDataSource {
    func dataTableViewControllerNumberOfItems(_ controller: DataTableViewController) -> Int {
        dataSource?.viewControllerNumberOfItems(self) ?? 0
    }

    func dataTableViewControler(_ controller: DataTableViewController, itemAt index: Int) -> VisualItem? {
        dataSource?.viewControler(self, itemAt: index)
    }
}

// MARK: -
extension Model.SortingOrder {
    func toString() -> String {
        switch self {
        case .none:
            return "Unsorted Order".localized
        case .ascending:
            return "Ascending Order".localized
        case .descending:
            return "Descending Order".localized
        }
    }

    func toImage() -> UIImage? {
        let name: String

        switch self {
        case .none:
            name = "chevron.up.chevron.down"
        case .ascending:
            name = "chevron.up"
        case .descending:
            name = "chevron.down"
        }

        return UIImage(systemName: name)
    }
}
