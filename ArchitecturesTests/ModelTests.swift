//
//  ModelTests.swift
//  ArchitecturesTests
//
//  Created by developer on 08.12.2023.
//

import XCTest
@testable import Architectures

final class ModelTests: XCTestCase {
    override func setUpWithError() throws {
        modelDataProvider = ModelDataProvider(with: "com.ArchitecturesTests")
    }

    override func tearDownWithError() throws {
        modelDataProvider = nil
    }

    func testMVVM() throws {
        let model = Model.MVVM(with: modelDataProvider)

        var callsCount = 0
        var lastCount = 0

        let cancellable = model.structure.bind { value  in
            lastCount = value.count
            callsCount += 1
        }

        var step = 0
        model.sortingOrder = .none

        XCTAssertTrue(model.structure.isInUse)
        XCTAssertEqual(callsCount, 0)
        XCTAssertEqual(lastCount, 0)

        step += 1
        model.reload()
        let noneStructure = model.structure.value.map { $0.testDescription() }

        XCTAssertEqual(callsCount, step)
        XCTAssertNotEqual(lastCount, 0)
        XCTAssertEqual(noneStructure.count, lastCount)

        step += 1
        model.sortingOrder = .ascending
        XCTAssertEqual(callsCount + 1, step)

        model.reload()
        let ascendingStructure = model.structure.value.map { $0.testDescription() }

        XCTAssertEqual(callsCount, step)
        XCTAssertEqual(noneStructure.count, ascendingStructure.count)
        XCTAssertNotEqual(noneStructure, ascendingStructure)

        step += 1
        model.sortingOrder = .descending
        model.reload()
        let descendingStructure = model.structure.value.map { $0.testDescription() }

        XCTAssertEqual(callsCount, step)
        XCTAssertEqual(ascendingStructure.count, descendingStructure.count)
        XCTAssertNotEqual(noneStructure, descendingStructure)
        XCTAssertNotEqual(ascendingStructure, descendingStructure)

        step += 1
        model.clear()

        XCTAssertEqual(callsCount, step)
        XCTAssertEqual(lastCount, 0)
        XCTAssertTrue(model.structure.value.isEmpty)

        cancellable.cancel()
        XCTAssertFalse(model.structure.isInUse)
    }

    private var modelDataProvider: DataProviderInterface!
}
