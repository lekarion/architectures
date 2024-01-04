//
//  ImagesProvider.swift
//  Architectures
//
//  Created by developer on 04.01.2024.
//

import UIKit

class ImagesProvider: ImagesProviderInterface {
    init(with identifier: String) {
        self.identifier = identifier
    }

    let identifier: String

    func image(for item: DataItemInterface) -> UIImage? {
        nil
    }

    func cacheImage(for item: DataItemInterface) {
    }
}
