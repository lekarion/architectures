//
//  ArchitecturesTests.swift
//  ArchitecturesTests
//
//  Created by developer on 06.12.2023.
//

import XCTest
@testable import Architectures

final class ArchitecturesTests: XCTestCase {
    override func setUpWithError() throws {
        modelDataProvider = ModelDataProvider(with: "com.ArchitecturesTests")
    }

    override func tearDownWithError() throws {
        modelDataProvider = nil
        currentExpectation = nil
    }

    func testPermanentLoading() throws {
        modelDataProvider.sortingOrder = .none
        let noneData = modelDataProvider.reload().map { $0.testDescription() }

        XCTAssertFalse(noneData.isEmpty)

        modelDataProvider.sortingOrder = .ascending
        let ascendingData = modelDataProvider.reload().map { $0.testDescription() }

        XCTAssertEqual(noneData.count, ascendingData.count)
        XCTAssertNotEqual(noneData, ascendingData)

        modelDataProvider.sortingOrder = .descending
        let descendingData = modelDataProvider.reload().map { $0.testDescription() }

        XCTAssertEqual(ascendingData.count, descendingData.count)
        XCTAssertNotEqual(noneData, descendingData)
        XCTAssertNotEqual(ascendingData, descendingData)
    }

    func testModifiedLoading() throws {
        modelDataProvider.sortingOrder = .none
        _ = modelDataProvider.reload()
        modelDataProvider.merge([]) // reset modified items if they was loaded from file

        let noneData = modelDataProvider.reload().map { $0.testDescription() }

        XCTAssertFalse(noneData.isEmpty)

        let testItemTitles = ["test1", "test2", "test3"]

        modelDataProvider.merge(testItemTitles.map {
            TestDataItem(iconName: nil, title: $0, description: "\($0) description")
        })
        let noneModifiedData = modelDataProvider.reload().map { $0.testDescription() }

        XCTAssertEqual(noneData.count + testItemTitles.count, noneModifiedData.count)

        modelDataProvider.sortingOrder = .ascending
        let ascendingModifiedData = modelDataProvider.reload().map { $0.testDescription() }

        XCTAssertEqual(noneModifiedData.count, ascendingModifiedData.count)
        XCTAssertNotEqual(noneModifiedData, ascendingModifiedData)

        modelDataProvider.sortingOrder = .descending
        let descendingModifiedData = modelDataProvider.reload().map { $0.testDescription() }

        XCTAssertEqual(ascendingModifiedData.count, descendingModifiedData.count)
        XCTAssertNotEqual(noneModifiedData, descendingModifiedData)
        XCTAssertNotEqual(ascendingModifiedData, descendingModifiedData)

        modelDataProvider.flush()

        let testProvider = ModelDataProvider(with: (modelDataProvider as! ModelDataProvider).identifier)

        testProvider.sortingOrder = .none
        let noneTestData = testProvider.reload().map { $0.testDescription() }

        XCTAssertEqual(noneModifiedData.count, noneTestData.count)
    }

    struct TestDataItem: DataItemInterface {
        let iconName: String?
        let title: String
        let description: String?
    }

    var modelDataProvider: DataProviderInterface!
    var currentExpectation: XCTestExpectation?
}
