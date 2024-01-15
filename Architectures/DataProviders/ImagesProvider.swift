//
//  ImagesProvider.swift
//  Architectures
//
//  Created by developer on 04.01.2024.
//

import UIKit

class ImagesProvider: ImagesProviderInterface {
    init(with identifier: String, thumbnailSize: CGSize) {
        self.identifier = identifier

        guard let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            fatalError("Invalid app state")
        }

        rootURL = url.appendingPathComponent(identifier, conformingTo: .directory)
        restoreRootIfNeed()
    }

    func image(named: String) -> UIImage? {
        if let builtIn = UIImage(named: "Emblems/\(named)") { return builtIn }
        if let loaded = registry[named] { return loaded.thumbnail }
        return nil
    }

    func clone(imageNamed source: String, to name: String) {
//        guard let fileURL = fileURL(for: item) else { return }
//        guard !FileManager.default.fileExists(atPath: fileURL.path) else { return }

        // TODO: make cloned image
    }

    func clone(image: UIImage, to name: String) {
    }

    func reset() {
    }

    private let identifier: String
    private let rootURL: URL
    private var registry = [String: ImageRegistryItem]()
}

private extension ImagesProvider {
    func fileURL(for item: DataItemInterface) -> URL? {
        guard nil != item.originalTitle else { return nil }
        guard let imageId = item.iconName else { return nil }

        return rootURL.appendingPathComponent(imageId, conformingTo: .png)
    }

    func restoreRootIfNeed() {
        let manager = FileManager.default

        var isFolder: ObjCBool = false
        guard !manager.fileExists(atPath: rootURL.path, isDirectory: &isFolder) || !isFolder.boolValue else { return }

        do {
            try manager.createDirectory(at: rootURL, withIntermediateDirectories: true)
        } catch {
            print("ImagesProvider: \(#function); \(error.localizedDescription)")
        }
    }
}

protocol ImageRegistryItem: AnyObject {
    var image: UIImage? { get }
    var thumbnail: UIImage? { get }

    func configure(thumbnailSize: CGSize)
}
