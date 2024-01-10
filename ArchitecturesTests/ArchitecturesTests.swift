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
        imagesProvider = ImagesProvider(with: Self.identifier)
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
        modelDataProvider.merge([], autoFlush: true) // reset modified items if they was loaded from file

        let noneData = modelDataProvider.reload().map { $0.testDescription() }

        XCTAssertFalse(noneData.isEmpty)

        let testItemTitles = ["test1", "test2", "test3"]

        modelDataProvider.merge(testItemTitles.map {
            TestDataItem(iconName: nil, title: $0, description: "\($0) description")
        }, autoFlush: false)
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

    func testDataDuplication() throws {
        modelDataProvider.sortingOrder = .none
        _ = modelDataProvider.reload()
        modelDataProvider.merge([], autoFlush: false) // reset modified items if they was loaded from file

        let originalData = modelDataProvider.reload()
        let noneData = originalData.map { $0.testDescription() }

        XCTAssertFalse(noneData.isEmpty)

        let count = min(3, originalData.count)
        let duplicatedItems = modelDataProvider.duplicate(Array(originalData[0 ..< count]))

        XCTAssertEqual(duplicatedItems.count, count)
        XCTAssertEqual(duplicatedItems.compactMap({ $0.originalTitle }).count, count)
        XCTAssertEqual(duplicatedItems.compactMap({ $0.iconName }).count, count)

        modelDataProvider.merge(duplicatedItems, autoFlush: false)

        let allItems = modelDataProvider.reload()
        let duplicatedData = allItems.map { $0.testDescription() }

        XCTAssertEqual(noneData.count + count, duplicatedData.count)
        XCTAssertEqual(Set(allItems.map({ $0.title })).count, noneData.count + count)

        let duplicatedItems2 = modelDataProvider.duplicate(Array(originalData[0 ..< count]))
        XCTAssertTrue(duplicatedItems2.isEmpty)

        print(duplicatedData.description)

        modelDataProvider.flush()

        let testDataProvider = ModelDataProvider(with: Self.identifier)
        let testModelData = testDataProvider.reload().map { $0.testDescription() }

        XCTAssertEqual(testModelData, duplicatedData)
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

            self.settingsDataProvider.presentationDimmingColor = nil
            XCTAssertNil(self.settingsDataProvider.presentationDimmingColor)

            let color = UIColor.white
            self.settingsDataProvider.presentationDimmingColor = color
            XCTAssertEqual(self.settingsDataProvider.presentationDimmingColor, color)

            self.settingsDataProvider.presentationDimmingColor = UIColor.red
            XCTAssertNotEqual(self.settingsDataProvider.presentationDimmingColor, color)

            self.settingsDataProvider.presentationInAnimationDirection = .centerZoom
            XCTAssertEqual(self.settingsDataProvider.presentationInAnimationDirection, .centerZoom)

            self.settingsDataProvider.presentationInAnimationDirection = .fromBottomToTop
            XCTAssertNotEqual(self.settingsDataProvider.presentationInAnimationDirection, .centerZoom)

            self.settingsDataProvider.presentationOutAnimationDirection = .fromTopToBottom
            XCTAssertEqual(self.settingsDataProvider.presentationOutAnimationDirection, .fromTopToBottom)
            XCTAssertNotEqual(self.settingsDataProvider.presentationOutAnimationDirection, self.settingsDataProvider.presentationInAnimationDirection)
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
        let originalTitle: String? = nil
        let description: String?
    }

    var modelDataProvider: DataProviderInterface!
    var settingsDataProvider: SettingsDataProvider!
    var imagesProvider: ImagesProviderInterface!
    var currentExpectation: XCTestExpectation?

    let executionQueue = DispatchQueue(label: "com.architecturesTests.executionQueue", qos: .userInteractive)

    static let identifier = "com.architecturesTests"
}
