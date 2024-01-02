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
        case let menuCell as MenuButtonCellInterface:
            setup(menu: menuCell, identifier: cell.reuseIdentifier ?? "")
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

    func setup(menu cell: MenuButtonCellInterface, identifier: String) {
        switch identifier {
        case Self.inDirectionCellId:
            cell.menu = PresentationAnimationDirection.directionMenu("In Direction".localized, context: MenuContext(with: cell, settings: settings, handler: {
                $0?.stateImage = $3
                $1?.presentationInAnimationDirection = $2
            }))
            cell.stateImage = (settings?.presentationInAnimationDirection ?? .centerZoom).toImage()
        case Self.outDirectionCellId:
            cell.menu = PresentationAnimationDirection.directionMenu("Out Direction".localized, context: MenuContext(with: cell, settings: settings, handler: {
                $0?.stateImage = $3
                $1?.presentationOutAnimationDirection = $2
            }))
            cell.stateImage = (settings?.presentationOutAnimationDirection ?? .centerZoom).toImage()
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

private protocol MenuContextInterface: AnyObject {
    func perform(action: UIAction, for direction: PresentationAnimationDirection)
}

private extension SettingsViewController {
    class MenuContext: MenuContextInterface {
        typealias ActionHandler = (MenuButtonCellInterface?, SettingsProviderInterface?, PresentationAnimationDirection, UIImage?) -> Void

        init(with cell: MenuButtonCellInterface?, settings: SettingsProviderInterface?, handler: @escaping ActionHandler) {
            self.cell = cell
            self.settings = settings
            self.actionHandler = handler
        }

        func perform(action: UIAction, for direction: PresentationAnimationDirection) {
            actionHandler(cell, settings, direction, action.image)
        }

        private weak var cell: MenuButtonCellInterface?
        private weak var settings: SettingsProviderInterface?
        private let actionHandler: ActionHandler
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
        let name: String
        switch self {
        case .centerZoom:
            name = "square.arrowtriangle.4.outward"
        case .fromBottomToTop:
            name = "arrow.up.to.line.square"
        case .fromLeftToRight:
            name = "arrow.right.to.line.square"
        case .fromRightToLeft:
            name = "arrow.left.to.line.square"
        case .fromTopToBottom:
            name = "arrow.down.to.line.square"
        }
        return UIImage(systemName: name)
    }

    static func directionMenu(_ title: String, context: MenuContextInterface) -> UIMenu {
        UIMenu(title: title, options: .displayInline, children: allCases.map({ order in
            UIAction(title: order.toString(), image: order.toImage(), handler: {
                context.perform(action: $0, for: order)
            })
        }))
    }
}
