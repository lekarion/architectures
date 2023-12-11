//
//  ViewController.swift
//  Architectures
//
//  Created by developer on 08.12.2023.
//

import UIKit

protocol ViewInterface: AnyObject {
    var clearButtonEnabled: Bool { get set }
    var reloadButtonEnabled: Bool { get set }
    var sortingOrderButtonEnabled: Bool { get set }

    var sortingOrder: Model.SortingOrder { get set }
    var dataSource: ViewDataSource? { get set }
    var delegate: ViewDelegate? { get set }

    func reloadData()
}

protocol ViewDataSource: AnyObject {
    func viewControllerNumberOfItems(_ view: ViewInterface) -> Int
    func viewControler(_ view: ViewInterface, itemAt index: Int) -> VisualItem
}

protocol ViewDelegate: AnyObject {
    func viewController(_ view: ViewInterface, sortingOrderDidChange: Model.SortingOrder)
    func viewControllerDidRequestClear(_ view: ViewInterface)
    func viewControllerDidRequestReload(_ view: ViewInterface)
}

class ViewController: UIViewController, ViewInterface {
    weak var dataSource: ViewDataSource?
    weak var delegate: ViewDelegate?

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

                self.delegate?.viewController(self, sortingOrderDidChange: order)
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

    private var dataViewController: DataViewControllerInterface!
}

extension ViewController { // Actions
    @IBAction func onReloadButton(_ sender: UIButton) {
        delegate?.viewControllerDidRequestReload(self)
    }

    @IBAction func onClearButton(_ sender: UIButton) {
        delegate?.viewControllerDidRequestClear(self)
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
