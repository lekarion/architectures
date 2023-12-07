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
                guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else { break }

                let url = URL(fileURLWithPath: path, isDirectory: false).appendingPathComponent("\(identifier).json", conformingTo: .json)

                guard let data = try? Data(contentsOf: url), !data.isEmpty else { break }
                guard let structure = try? JSONDecoder().decode([DataItem].self, from: data) else { break }

                result = structure
            } while false

            mutableStructure = result
        }

        structure = Self.permanentStructure + mutableStructure!
        loaded = true

        return structure
    }

    private let identifier: String
    private var mutableStructure: [DataItemInterface]?
    private var structure = [DataItemInterface]()
    private var loaded = false
}

private extension ModelDataProvider {
    struct DataItem: DataItemInterface, Decodable {
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
}
