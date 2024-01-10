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

    let identifier: String

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
                guard let data = try? Data(contentsOf: urlToFile), !data.isEmpty else { break }
                guard let structure = try? JSONDecoder().decode([DataItem].self, from: data) else { break }

                result = structure.compactMap{ Self.permanentNames.contains($0.title) ? nil : $0 }
            } while false

            mutableStructure = result
        }

        structure = Self.permanentStructure + mutableStructure!

        switch sortingOrder {
        case .ascending:
            structure.sort { lhs, rhs in
                lhs.title < rhs.title
            }
        case .descending:
            structure.sort { lhs, rhs in
                lhs.title > rhs.title
            }
        default:
            break
        }

        loaded = true

        return structure
    }

    func merge(_ items: [DataItemInterface], autoFlush: Bool) {
        var validationTitles = Set<String>()
        mutableStructure = items.compactMap {
            guard !Self.permanentNames.contains($0.title) else { return nil }

            let effectiveTitle = $0.originalTitle ?? $0.title
            guard !validationTitles.contains(effectiveTitle) else { return nil }

            validationTitles.insert(effectiveTitle)

            return DataItem(iconName: $0.iconName, title: $0.title, originalTitle: $0.originalTitle, description: $0.description)
        }

        loaded = false
        flushed = false

        guard autoFlush else { return }

        flushingQueue.async { [weak self] in
            self?.flush(forced: true)
        }
    }

    func duplicate(_ items: [DataItemInterface]) -> [DataItemInterface] {
        items.compactMap { [weak self] (item: DataItemInterface) -> DataItemInterface? in
            guard nil == item.originalTitle else { return nil }
            guard Self.permanentNames.contains(item.title) else { return nil }
            guard self?.mutableNames.contains(item.title) == false else { return nil }

            var newIconName = Self.duplicateIconNamePrefix + item.title
            var nameParts = [item.title, "duplicated"]
            if let iconName = item.iconName {
                nameParts.append(iconName)
                newIconName += iconName
            }

            return DataItem(iconName: newIconName, title: nameParts.joined(separator: Self.duplicateNameSeparator), originalTitle: item.title, description: item.description)
        }
    }

    func flush() {
        flush(forced: false)
    }

    private func flush(forced: Bool) {
        guard !flushed || forced else { return }

        let structure = mutableStructure as? [DataItem] ?? []

        do {
            let data = try JSONEncoder().encode(structure)
            try data.write(to: urlToFile)
            flushed = true
        } catch {
            "\(Self.logPrefix): \(#function); \(error)".printToStderr()
        }
    }

    private var mutableStructure: [DataItemInterface]? {
        didSet {
            mutableNames = Set(mutableStructure?.compactMap({ $0.originalTitle }) ?? [])
        }
    }
    private var mutableNames = Set<String>()

    private var structure = [DataItemInterface]()
    private var loaded = false
    private var flushed = true

    private lazy var urlToFile: URL = {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        return URL(fileURLWithPath: path ?? NSHomeDirectory(), isDirectory: true).appendingPathComponent("\(identifier).json", conformingTo: .json)
    }()

    private lazy var flushingQueue: DispatchQueue = {
        DispatchQueue(label: "com.modelDataProvider.flushingQueue", qos: .background)
    }()
}

private extension ModelDataProvider {
    static let logPrefix = "ModelDataProvider"
    static let duplicateNameSeparator = "-@-"
    static let duplicateIconNamePrefix = "transformedIcon."

    struct DataItem: DataItemInterface, Codable {
        let iconName: String?
        let title: String
        var originalTitle: String?
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
