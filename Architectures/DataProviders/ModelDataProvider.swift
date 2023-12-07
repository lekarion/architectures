//
//  ModelDataProvider.swift
//  Architectures
//
//  Created by developer on 07.12.2023.
//

import Foundation

class ModelDataProvider: DataProviderInterface {
    init(with identifier: String) {
        self.identifier = identifier
    }

    var sortingOrder: SortingOrder = .none {
        didSet {
            guard oldValue != sortingOrder else { return }
            loaded = false
        }
    }

    func reload() -> [DataItemInterface] {
        guard !loaded else { return structure }

        if nil == mutableStructure {
            var result = [DataItemInterface]()
            repeat {
                guard let data = try? Data(contentsOf: urlToFule), !data.isEmpty else { break }
                guard let structure = try? JSONDecoder().decode([DataItem].self, from: data) else { break }

                result = structure.compactMap{ Self.permanentNames.contains($0.title) ? nil : $0 }
            } while false

            mutableStructure = result
        }

        structure = Self.permanentStructure + mutableStructure!
        loaded = true

        return structure
    }

    func merge(_ items: [DataItemInterface]) {
        mutableStructure = items.compactMap { Self.permanentNames.contains($0.title) ? nil : $0 }
    }

    func flush() {
        let structure = mutableStructure as? [DataItem] ?? []

        guard let data = try? JSONEncoder().encode(structure) else { return }
        try? data.write(to: urlToFule)
    }

    private let identifier: String
    private var mutableStructure: [DataItemInterface]?
    private var structure = [DataItemInterface]()
    private var loaded = false

    private lazy var urlToFule: URL = {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        return URL(fileURLWithPath: path ?? NSHomeDirectory(), isDirectory: true).appendingPathComponent("\(identifier).json", conformingTo: .json)
    }()
}

private extension ModelDataProvider {
    struct DataItem: DataItemInterface, Codable {
        let iconName: String?
        let title: String
        let description: String?
    }

    static let permanentStructure: [DataItem] = {
        guard let url = Bundle.main.url(forResource: "ModelData", withExtension: "json") else { return [DataItem]() }
        guard let data = try? Data(contentsOf: url), !data.isEmpty else { return [DataItem]() }
        guard let structure = try? JSONDecoder().decode([DataItem].self, from: data) else { return [DataItem]() }
        return structure
    }()

    static let permanentNames: Set<String> = {
        let allNames = permanentStructure.map { $0.title }
        return Set(allNames)
    }()
}
