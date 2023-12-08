//
//  ModelTests.swift
//  ArchitecturesTests
//
//  Created by developer on 08.12.2023.
//

import XCTest
@testable import Architectures

extension ArchitecturesTests {
    func testMVVMModel() throws {
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

    func testMVVMViewModel() throws {
        let viewModel = ViewModel.MVVM()

        var callsCount = 0
        var lastCount = 0

        let cancellable = viewModel.structure.bind { [weak self] value in
            lastCount = value.count
            callsCount += 1

            self?.currentExpectation?.fulfill()
        }

        var step = 0
        viewModel.sortingOrder = .none

        XCTAssertTrue(viewModel.structure.isInUse)
        XCTAssertEqual(callsCount, 0)
        XCTAssertEqual(lastCount, 0)

        let structure = viewModel.structure.value.map { $0.testDescription() }
        XCTAssertEqual(callsCount, 0)
        XCTAssertEqual(lastCount, 0)
        XCTAssertNotEqual(structure.count, 0)

        currentExpectation = XCTestExpectation(description: "Waiting for reload")

        step += 1
        viewModel.reloadData()
        wait(for: [currentExpectation!])

        XCTAssertEqual(callsCount, step)
        XCTAssertGreaterThan(lastCount, structure.count)

        currentExpectation = XCTestExpectation(description: "Waiting for clear")

        step += 1
        viewModel.clearData()
        wait(for: [currentExpectation!])

        XCTAssertEqual(callsCount, step)
        XCTAssertEqual(lastCount, structure.count)

        cancellable.cancel()
        XCTAssertFalse(viewModel.structure.isInUse)
    }
}
