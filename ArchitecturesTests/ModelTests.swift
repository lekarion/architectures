//
//  ModelTests.swift
//  ArchitecturesTests
//
//  Created by developer on 08.12.2023.
//

import XCTest
@testable import Architectures

#if USE_COMBINE_FOR_VIEW_ACTIONS
import Combine
#endif // USE_COMBINE_FOR_VIEW_ACTIONS

extension ArchitecturesTests {
    func testMVVMModel() throws {
        let model = Model.MVVM(with: modelDataProvider)

        var cancellable: BindCancellable?
        try baseModelProcessing(model: model) {
            cancellable = model.structure.bind($0)
        }

        XCTAssertTrue(model.structure.isInUse)

        cancellable?.cancel()
        XCTAssertFalse(model.structure.isInUse)
    }

    func testMVVMViewModel() throws {
        let viewModelHolder = ViewModelHolder(ViewModel.MVVM())

        var cancellable: BindCancellable?
        try baseViewModelProcessing(viewModel: viewModelHolder) {
            cancellable = viewModelHolder.viewModel.structureBind.bind($0)
        }

        XCTAssertTrue(viewModelHolder.viewModel.structureBind.isInUse)

        cancellable?.cancel()
        XCTAssertFalse(viewModelHolder.viewModel.structureBind.isInUse)
    }
}

// MARK: - ### Reuse ### -
extension ArchitecturesTests {
    func baseModelProcessing<T: ModelInterface>(model: T, ignoreFirst: Bool = false, bind: (@escaping ([ModelItem]) -> Void) -> Void) throws {
        var callsCount = ignoreFirst ? -1 : 0
        var lastCount = model.rawStructure.count

        bind { value in
            callsCount += 1

            guard callsCount > 0 else { return }

            lastCount = value.count
        }

        var step = 0
        model.sortingOrder = .none

        XCTAssertEqual(callsCount, 0)
        XCTAssertEqual(lastCount, 0)

        step += 1
        model.reload()
        let noneStructure = model.rawStructure.map { $0.testDescription() }

        XCTAssertEqual(callsCount, step)
        XCTAssertNotEqual(lastCount, 0)
        XCTAssertEqual(noneStructure.count, lastCount)

        step += 1
        model.sortingOrder = .ascending
        XCTAssertEqual(callsCount + 1, step)

        model.reload()
        let ascendingStructure = model.rawStructure.map { $0.testDescription() }

        XCTAssertEqual(callsCount, step)
        XCTAssertEqual(noneStructure.count, ascendingStructure.count)
        XCTAssertNotEqual(noneStructure, ascendingStructure)

        step += 1
        model.sortingOrder = .descending
        model.reload()
        let descendingStructure = model.rawStructure.map { $0.testDescription() }

        XCTAssertEqual(callsCount, step)
        XCTAssertEqual(ascendingStructure.count, descendingStructure.count)
        XCTAssertNotEqual(noneStructure, descendingStructure)
        XCTAssertNotEqual(ascendingStructure, descendingStructure)

        step += 1
        model.clear()

        XCTAssertEqual(callsCount, step)
        XCTAssertEqual(lastCount, 0)
        XCTAssertTrue(model.rawStructure.isEmpty)
    }

    func baseViewModelProcessing<T: ViewModelInterface>(viewModel: ViewModelHolder<T>, ignoreFirst: Int = 0, bind: (@escaping ([VisualItem]) -> Void) -> Void) throws {
        let effectiveIgnoreFirst = 0 >= ignoreFirst ? 0 : -ignoreFirst

        var callsCount = effectiveIgnoreFirst
        var lastCount = viewModel.rawStructure.count

        currentExpectation = XCTestExpectation(description: "Waiting for init")
        currentExpectation?.isInverted = true
        bind { [weak self] value in
            callsCount += 1

            guard callsCount >= 0 else { return }

            lastCount = value.count
            self?.currentExpectation?.fulfill()
        }

        if 0 != effectiveIgnoreFirst {
            wait(for: [currentExpectation!], timeout: 5.0)
        }

        var step = 0
        viewModel.sortingOrder = .none

        XCTAssertEqual(callsCount, 0)
        XCTAssertNotEqual(lastCount, 0)

        let emptyCount = lastCount

        let structure = viewModel.rawStructure.map { $0.testDescription() }
        XCTAssertEqual(callsCount, 0)
        XCTAssertEqual(lastCount, emptyCount)
        XCTAssertEqual(structure.count, emptyCount)

        currentExpectation = XCTestExpectation(description: "Waiting for reload")

        step += 1
        viewModel.reloadData()
        wait(for: [currentExpectation!], timeout: 2.0)

        XCTAssertEqual(callsCount, step)
        XCTAssertGreaterThan(lastCount, structure.count)

        currentExpectation = XCTestExpectation(description: "Waiting for clear")

        step += 1
        viewModel.clearData()
        wait(for: [currentExpectation!], timeout: 2.0)

        XCTAssertEqual(callsCount, step)
        XCTAssertEqual(lastCount, structure.count)
    }

    class ViewModelHolder<T: ViewModelInterface>: ViewModelActionInterface {
        init(_ viewModel: T) {
            self.viewModel = viewModel
        #if USE_COMBINE_FOR_VIEW_ACTIONS
            viewModel.setup(with: self)
        #endif // USE_COMBINE_FOR_VIEW_ACTIONS
        }

        let viewModel: T

        var rawStructure: [VisualItem] { viewModel.structure }
        var sortingOrder: Model.SortingOrder {
            get { viewModel.sortingOrder }
            set {
                #if USE_COMBINE_FOR_VIEW_ACTIONS
                    subject.send(.changeSortingOrder(order: newValue))
                #else
                    viewModel.sortingOrder = newValue
                #endif // USE_COMBINE_FOR_VIEW_ACTIONS
            }
        }

        func reloadData() {
        #if USE_COMBINE_FOR_VIEW_ACTIONS
            subject.send(.reload)
        #else
            viewModel.reloadData()
        #endif // USE_COMBINE_FOR_VIEW_ACTIONS
        }

        func clearData() {
        #if USE_COMBINE_FOR_VIEW_ACTIONS
            subject.send(.clear)
        #else
            viewModel.clearData()
        #endif // USE_COMBINE_FOR_VIEW_ACTIONS
        }

    #if USE_COMBINE_FOR_VIEW_ACTIONS
        var actionEvent: AnyPublisher<ViewModelAction, Never> { subject.eraseToAnyPublisher() }
        private let subject = PassthroughSubject<ViewModelAction, Never>()
    #endif // USE_COMBINE_FOR_VIEW_ACTIONS
    }
}
