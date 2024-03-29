//
//  DataTableViewController.swift
//  Architectures
//
//  Created by developer on 30.11.2023.
//

import UIKit

protocol DataViewControllerInterface: AnyObject {
    var dataSource: DataTableViewControllerDataSource? { get set }
    var delegate: DataTableViewControllerDelegate? { get set }

    func reloadData()
}

protocol DataTableViewControllerDataSource: AnyObject {
    func dataTableViewControllerNumberOfItems(_ controller: DataTableViewController) -> Int
    func dataTableViewController(_ controller: DataTableViewController, itemAt index: Int) -> VisualItem?
}

protocol DataTableViewControllerDelegate: AnyObject {
    func dataTableViewController(_ controller: DataTableViewController, isDuplicationAvailableFor item: VisualItem) -> Bool
    func dataTableViewController(_ controller: DataTableViewController, didRequestDuplicate item: VisualItem)
}

// MARK: -
class DataTableViewController: UITableViewController, DataViewControllerInterface {
    weak var dataSource: DataTableViewControllerDataSource?
    weak var delegate: DataTableViewControllerDelegate?

    func reloadData() {
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource?.dataTableViewControllerNumberOfItems(self) ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = dataSource?.dataTableViewController(self, itemAt: indexPath.row) else { return UITableViewCell() }

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

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        !(dataSource?.dataTableViewController(self, itemAt: indexPath.row) is SchemeItem)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == Self.showDetailsSegueId else { return }
        guard let detailsView = segue.destination as? DetailsViewInterface else { return }
        guard let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) else { return }
        guard let item = dataSource?.dataTableViewController(self, itemAt: indexPath.row) as? DetailsItem else { return }

        detailsView.show(item: item)
        detailsView.actionDelegate = self
    }

    private var currentTransitioningDelegate: PresentationTransitioningDelegate?
    private weak var settings: SettingsProviderInterface? = {
        guard let appCoordinator = UIApplication.shared.delegate as? AppCoordinator else {
            fatalError("Invalid app state")
        }

        return appCoordinator.settingsProvider(for: AppDelegate.genericSettingsProviderId)
    }()
}

extension DataTableViewController: DetailsViewActionDelegate {
    func detailsView(_ view: DetailsViewInterface, isDuplicationAvailableFor item: DetailsItem) -> Bool {
        delegate?.dataTableViewController(self, isDuplicationAvailableFor: item) ?? false
    }

    func detailsView(_ view: DetailsViewInterface, didRequestDuplicate item: DetailsItem) {
        delegate?.dataTableViewController(self, didRequestDuplicate: item)
    }

    func detailsViewDidFinish(_ view: DetailsViewInterface) {
        guard let controller = view as? UIViewController else { return }
        controller.dismiss(animated: true)
    }
}

extension DataTableViewController: CustomPresentationSourceInterface {
    var customTransitioningDelegate: UIViewControllerTransitioningDelegate {
        currentTransitioningDelegate = PresentationTransitioningDelegate()
        return currentTransitioningDelegate!
    }
}

extension DataTableViewController: PresentationSettingsProvider, PresentationAnimationSettingsProvider {
    var style: PresentationDimmingStyle { .color }
    var color: UIColor { settings?.presentationDimmingColor ?? UIColor.systemBlue.withAlphaComponent(0.65) }

    var presentingAnimation: PresentationAnimationDirection { settings?.presentationInAnimationDirection ?? .centerZoom }
    var dismissingAnimation: PresentationAnimationDirection { settings?.presentationOutAnimationDirection ?? .centerZoom }
}

private extension DataTableViewController {
    static let prefixCellId = "com.visual.cell"
    static let dataCellId = "com.info.cell"
    static let showDetailsSegueId = "com.show.details"
}

// MARK: -
protocol SchemeCellInterface: AnyObject {
    func setup(with item: SchemeItem)
}

protocol DataCellInterface: AnyObject {
    func setup(with item: DetailsItem)
}
