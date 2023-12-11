//
//  DataTableViewController.swift
//  Architectures
//
//  Created by developer on 30.11.2023.
//

import UIKit

protocol DataViewControllerInterface: AnyObject {
    var dataSource: DataTableViewControllerDataSource? { get set }

    func reloadData()
}

protocol DataTableViewControllerDataSource: AnyObject {
    func dataTableViewControllerNumberOfItems(_ controller: DataTableViewController) -> Int
    func dataTableViewControler(_ controller: DataTableViewController, itemAt index: Int) -> VisualItem?
}

class DataTableViewController: UITableViewController, DataViewControllerInterface {
    weak var dataSource: DataTableViewControllerDataSource?

    func reloadData() {
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource?.dataTableViewControllerNumberOfItems(self) ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = dataSource?.dataTableViewControler(self, itemAt: indexPath.row) else { return UITableViewCell() }

        let cell: UITableViewCell

        switch item {
        case let schemeItem as SchemeItem:
            guard let schemeCell = tableView.dequeueReusableCell(withIdentifier: Self.prefixCellId, for: indexPath) as? SchemeCellInterface else {
                cell = UITableViewCell()
                break
            }

            schemeCell.setup(with: schemeItem)
            cell = schemeCell as! UITableViewCell
        case let dataItem as DetailsItem:
            guard let dataCell = tableView.dequeueReusableCell(withIdentifier: Self.dataCellId, for: indexPath) as? DataCellInterface else {
                cell = UITableViewCell()
                break
            }

            dataCell.setup(with: dataItem)
            cell = dataCell as! UITableViewCell
        default:
            cell = UITableViewCell()
        }

        return cell
    }
}

extension DataTableViewController {
    static let prefixCellId = "com.visual.cell"
    static let dataCellId = "com.info.cell"
}

protocol SchemeCellInterface: AnyObject {
    func setup(with item: SchemeItem)
}

protocol DataCellInterface: AnyObject {
    func setup(with item: DetailsItem)
}
