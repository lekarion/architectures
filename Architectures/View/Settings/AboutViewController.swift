//
//  AboutViewController.swift
//  Architectures
//
//  Created by developer on 26.12.2023.
//

import UIKit

class AboutViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let bundle = Bundle.main

        appNameLabel.text = Self.appName(for: bundle)
        appVersionLabel.text = Self.appVarsion(for: bundle)

        if let copyright = Self.appCopyright(for: bundle) {
            appCopyrightLabel.isHidden = false
            appCopyrightLabel.text = copyright
        } else {
            appCopyrightLabel.isHidden = true
        }
    }

    @IBOutlet private weak var appNameLabel: UILabel!
    @IBOutlet private weak var appVersionLabel: UILabel!
    @IBOutlet private var appCopyrightLabel: UILabel!
}

private extension AboutViewController {
    static func appName(for bundle: Bundle) -> String {
        let name: String
        if let displayName = bundle.localizedInfoDictionary?["CFBundleDisplayName"] as? String {
            name = displayName
        } else {
            name = (bundle.infoDictionary?["CFBundleName"] as? String) ?? ""
        }

        return name
    }

    static func appVarsion(for bundle: Bundle) -> String {
        String(format: NSLocalizedString("Version %@ (%@)", comment: ""), (bundle.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "1.0.0", (bundle.infoDictionary?["CFBundleVersion"] as? String) ?? "1")
    }

    static func appCopyright(for bundle: Bundle) -> String? {
        bundle.localizedInfoDictionary?["NSHumanReadableCopyright"] as? String
    }
}
