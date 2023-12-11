//
//  String+Localization.swift
//  Architectures
//
//  Created by developer on 30.11.2023.
//

import Foundation

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
	}
}
