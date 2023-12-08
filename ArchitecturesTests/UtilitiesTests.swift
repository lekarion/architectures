//
//  UtilitiesTests.swift
//  ArchitecturesTests
//
//  Created by developer on 08.12.2023.
//

import XCTest
@testable import Architectures

final class UtilitiesTests: XCTestCase {
    func testBinding() throws {
        let testBindValue = GenericBind(value: 0)

        XCTAssertFalse(testBindValue.isInUse)

        var callsCount = 0
        var lastValue = 0

        let cancellable = testBindValue.bind { value in
            lastValue = value
            callsCount += 1
        }

        XCTAssertTrue(testBindValue.isInUse)

        testBindValue.value = 1
        XCTAssertEqual(callsCount, 1)
        XCTAssertEqual(lastValue, 1)

        testBindValue.value = 5
        XCTAssertEqual(callsCount, 2)
        XCTAssertEqual(lastValue, 5)

        cancellable.cancel()

        testBindValue.value = 100
        XCTAssertEqual(callsCount, 2)
        XCTAssertEqual(lastValue, 5)
    }

    func testMultiBinding() throws {
        let testBindValue = GenericBind(value: 0)

        var callsCount = [0, 0]
        var lastValue = [0, 0]

        let cancellable0 = testBindValue.bind { value in
            lastValue[0] = value
            callsCount[0] += 1
        }

        let cancellable1 = testBindValue.bind { value in
            lastValue[1] = value
            callsCount[1] += 1
        }

        testBindValue.value = 1
        XCTAssertEqual(callsCount[0], 1)
        XCTAssertEqual(lastValue[0], 1)
        XCTAssertEqual(callsCount[1], 1)
        XCTAssertEqual(lastValue[1], 1)

        testBindValue.value = 5
        XCTAssertEqual(callsCount[0], 2)
        XCTAssertEqual(lastValue[0], 5)
        XCTAssertEqual(callsCount[1], 2)
        XCTAssertEqual(lastValue[1], 5)

        cancellable0.cancel()

        testBindValue.value = 7
        XCTAssertEqual(callsCount[0], 2)
        XCTAssertEqual(lastValue[0], 5)
        XCTAssertEqual(callsCount[1], 3)
        XCTAssertEqual(lastValue[1], 7)

        cancellable1.cancel()

        testBindValue.value = 100
        XCTAssertEqual(callsCount[0], 2)
        XCTAssertEqual(lastValue[0], 5)
        XCTAssertEqual(callsCount[1], 3)
        XCTAssertEqual(lastValue[1], 7)
    }

    func testBindingARC() throws {
        let testBindValue = GenericBind(value: 0)

        var callsCount = 0
        var lastValue = 0

        testBindValue.value = 1
        XCTAssertEqual(callsCount, 0)
        XCTAssertEqual(lastValue, 0)

        XCTAssertFalse(testBindValue.isInUse)

        var cancellable: BindCancellable?
        cancellable = testBindValue.bind { value in
            lastValue = value
            callsCount += 1
        }

        XCTAssertTrue(testBindValue.isInUse)

        testBindValue.value = 5
        XCTAssertEqual(callsCount, 1)
        XCTAssertEqual(lastValue, 5)

        cancellable = nil
        XCTAssertFalse(testBindValue.isInUse)

        testBindValue.value = 100
        XCTAssertEqual(callsCount, 1)
        XCTAssertEqual(lastValue, 5)
    }
}
