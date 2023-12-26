//
//  SettingsViewController.swift
//  Architectures
//
//  Created by developer on 26.12.2023.
//

import UIKit

class SettingsViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let appCoordinator = UIApplication.shared.delegate as? AppCoordinator else { return }
        settings = appCoordinator.settingsProvider(for: AppDelegate.genericSettingsProviderId)
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard !onceInitedCellPaths.contains(indexPath) else { return }

        switch cell {
        case let colorSelectionCell as ColorSelectionCellInterface:
            setup(colorSelection: colorSelectionCell, identifier: cell.reuseIdentifier ?? "")
        default:
            break
        }

        onceInitedCellPaths.insert(indexPath)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedCell = tableView.cellForRow(at: indexPath) as? ActionActivationCellInterface {
            selectedCell.activateAction(presenter: self)
        }

        DispatchQueue.main.async {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    private weak var settings: SettingsProviderInterface?
    private var onceInitedCellPaths = Set<IndexPath>()
}

private extension SettingsViewController {
    static let colorCellId = "com.color.cell"
    static let inDirectionCellId = "com.inDirection.cell"
    static let outDirectionCellId = "com.outDirection.cell"

    func setup(colorSelection cell: ColorSelectionCellInterface, identifier: String) {
        switch identifier {
        case Self.colorCellId:
            cell.color = settings?.presentationDimmingColor
            cell.delegate = self
        default:
            break
        }
    }
}

extension SettingsViewController: ColorSelectionCellDelegate {
    func colorSelectionCell(_ cell: ColorSelectionCellInterface, didChange color: UIColor?) {
        settings?.presentationDimmingColor = color
    }
}

private extension PresentationAnimationDirection {
    func toString() -> String {
        switch self {
        case .centerZoom:
            return "Zoom from Center".localized
        case .fromBottomToTop:
            return "From Bottom to Top".localized
        case .fromLeftToRight:
            return "From Left to Right".localized
        case .fromRightToLeft:
            return "From Right to Left".localized
        case .fromTopToBottom:
            return "From Top to Bottom".localized
        }
    }

    func toImage() -> UIImage? {
        nil
    }
}
