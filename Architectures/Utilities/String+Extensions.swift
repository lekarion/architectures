//
//  String+Extensions.swift
//  Architectures
//
//  Created by developer on 09.01.2024.
//

import Foundation

extension String {
    func printToStderr() {
        guard let data = self.data(using: .utf8) else { return }
        FileHandle.standardError.write(data)
    }
}
