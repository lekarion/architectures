//
//  ViewController.swift
//  Architectures
//
//  Created by developer on 08.12.2023.
//

import UIKit

protocol ViewControllerInterface: AnyObject {
    var structure: [VisualItem] { get }
    var sortingOrder: Model.SortingOrder { get set }

    var delegate: ViewControllerDelegate? { get set }

    func reloadData()
    func clearData()
}

protocol ViewControllerDelegate: AnyObject {
    func interfaceDidChangeStructure(_ interface: ViewControllerInterface)
}

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let interfaceController = parent as? ViewControllerInterface else {
            fatalError("No interface controller found")
        }

        guard let dataViewController = children.first(where: { $0 is DataViewControllerInterface }) as? DataViewControllerInterface else {
            fatalError("No data controller found")
        }

        let sortingMenu = UIMenu(title: "Sorting in", options: .displayInline, children: Model.SortingOrder.allCases.map({ order in
            UIAction(title:order.toString(), image: order.toImage(), handler: { [weak self] in
                self?.interface.sortingOrder = order
                self?.sortingButton.setTitle($0.title, for: .normal)
                self?.sortingButton.setImage($0.image, for: .normal)
            })
        }))

        sortingButton.menu = sortingMenu
        sortingButton.showsMenuAsPrimaryAction = true

        self.interface = interfaceController
        self.dataViewController = dataViewController
        self.dataViewController?.structure = interface.structure

        sortingButton.setTitle(interface.sortingOrder.toString(), for: .normal)
        sortingButton.setImage(interface.sortingOrder.toImage(), for: .normal)
    }

    @IBOutlet private weak var clearButton: UIButton!
    @IBOutlet private weak var sortingButton: UIButton!
    @IBOutlet private weak var reloadButton: UIButton!

    private weak var interface: ViewControllerInterface!
    private var dataViewController: DataViewControllerInterface!
}

extension ViewController { // Actions
    @IBAction func onReloadButton(_ sender: UIButton) {
        interface.reloadData()
    }

    @IBAction func onClearButton(_ sender: UIButton) {
        interface.clearData()
    }
}

// MARK: -
protocol DataViewControllerInterface: AnyObject {
    var structure: [VisualItem] { get set }
}

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
