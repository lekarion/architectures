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
        modelDataProvider = ModelDataProvider(with: Self.identifier)
        settingsDataProvider = SettingsDataProvider(with: Self.identifier)
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

    func testSettingsOperations() throws {
        executeSync(description: "Wait for sortingOrder") {
            self.settingsDataProvider.sortingOrder = .none
            XCTAssertEqual(self.settingsDataProvider.sortingOrder, .none)

            self.settingsDataProvider.sortingOrder = .ascending
            XCTAssertEqual(self.settingsDataProvider.sortingOrder, .ascending)

            let otherSettingsProvider = SettingsDataProvider(with: "com.otherTestSettings")
            otherSettingsProvider.sortingOrder = .none

            XCTAssertEqual(otherSettingsProvider.sortingOrder, .none)
            XCTAssertNotEqual(otherSettingsProvider.sortingOrder, self.settingsDataProvider.sortingOrder)
            XCTAssertEqual(self.settingsDataProvider.sortingOrder, .ascending)
        }
    }

    func executeSync(description: String, closure: @escaping () -> Void) {
        let expectation = XCTestExpectation(description: description)
        executionQueue.async {
            closure()
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }

    struct TestDataItem: DataItemInterface {
        let iconName: String?
        let title: String
        let description: String?
    }

    var modelDataProvider: DataProviderInterface!
    var settingsDataProvider: SettingsDataProvider!
    var currentExpectation: XCTestExpectation?

    let executionQueue = DispatchQueue(label: "com.architecturesTests.executionQueue", qos: .userInteractive)

    static let identifier = "com.architecturesTests"
}
