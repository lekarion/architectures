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
    func testPlainModel() throws {
        let model = Model.PlainModel(with: modelDataProvider, imageProvider: imagesProvider)

        var cancellable: BindCancellable?
        try baseModelProcessing(model: model) {
            cancellable = model.structureBind.bind($0)
        }

        XCTAssertTrue(model.structureBind.isInUse)

        cancellable?.cancel()
        XCTAssertFalse(model.structureBind.isInUse)
    }

    func testMVVMViewModel() throws {
        let viewModelHolder = ViewModelHolder(ViewModel.MVVM(Self.identifier))

        var cancellable: BindCancellable?
        try baseViewModelProcessing(viewModel: viewModelHolder) {
            cancellable = viewModelHolder.viewModel.structureBind.bind($0)
        }

        XCTAssertTrue(viewModelHolder.viewModel.structureBind.isInUse)

        cancellable?.cancel()
        XCTAssertFalse(viewModelHolder.viewModel.structureBind.isInUse)
    }

    func testMVPPresenter() throws {
        let model = Model.PlainModel(with: modelDataProvider, imageProvider: imagesProvider)
        let view = TestMVPView()
        let presenter = Presenter.MVP("\(Self.identifier).mvp.combine")

        presenter.setup(with: model, view: view)
        XCTAssertNotNil(view.presenter)

        try baseMVVPProcessing(presenter: presenter, view: view)
    }
}

// MARK: - ### Reuse ### -
extension ArchitecturesTests {
    func baseModelProcessing<T: ModelInterface>(model: T, bind: (@escaping ([ModelItem]) -> Void) -> Void) throws {
        var callsCount = 0
        var lastCount = model.structure.count

        bind { value in
            callsCount += 1
            lastCount = value.count
        }

        var step = 0
        model.sortingOrder = .none

        XCTAssertEqual(callsCount, 0)
        XCTAssertEqual(lastCount, 0)

        step += 1
        model.reload()
        let noneStructure = model.structure.map { $0.testDescription() }

        XCTAssertEqual(callsCount, step)
        XCTAssertNotEqual(lastCount, 0)
        XCTAssertEqual(noneStructure.count, lastCount)

        step += 1
        model.sortingOrder = .ascending
        XCTAssertEqual(callsCount + 1, step)

        model.reload()
        let ascendingStructure = model.structure.map { $0.testDescription() }

        XCTAssertEqual(callsCount, step)
        XCTAssertEqual(noneStructure.count, ascendingStructure.count)
        XCTAssertNotEqual(noneStructure, ascendingStructure)

        step += 1
        model.sortingOrder = .descending
        model.reload()
        let descendingStructure = model.structure.map { $0.testDescription() }

        XCTAssertEqual(callsCount, step)
        XCTAssertEqual(ascendingStructure.count, descendingStructure.count)
        XCTAssertNotEqual(noneStructure, descendingStructure)
        XCTAssertNotEqual(ascendingStructure, descendingStructure)

        step += 1
        model.clear()

        XCTAssertEqual(callsCount, step)
        XCTAssertEqual(lastCount, 0)
        XCTAssertTrue(model.structure.isEmpty)
    }

    func baseViewModelProcessing<T: ViewModelInterface>(viewModel: ViewModelHolder<T>, bind: (@escaping ([VisualItem]) -> Void) -> Void) throws {
        var callsCount = 0
        var lastCount = viewModel.rawStructure.count

        currentExpectation = XCTestExpectation(description: "Waiting for init")
        bind { [weak self] value in
            callsCount += 1
            lastCount = value.count
            self?.currentExpectation?.fulfill()
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

extension ArchitecturesTests {
    class TestMVPView: TestMVPViewInterface, PresenterViewInterface {
    #if USE_BINDING_FOR_PALIN_MVP
        weak var presenter: PresenterInterface? {
            didSet {
                structureCancellable?.cancel()
                actionsCancellable?.cancel()

                guard let painPresenter = presenter as? PlainPresenterInterface else { return }

                structureCancellable = painPresenter.structureBind.bind { [weak self] in
                    self?.itemsCount = $0.count
                    self?.itemCallsCount += 1
                    self?.currentExpectation?.fulfill()
                }

                actionsCancellable = painPresenter.availableActionsBind.bind { [weak self] in
                    self?.isAllactions = $0 == Presenter.Actions.all
                    self?.actionCallsCount += 1
                    self?.currentExpectation?.fulfill()
                }
            }
        }

        func handle(update: Presenter.Update) {
            fatalError()
        }
    #else
        weak var presenter: PresenterInterface?

        func handle(update: Presenter.Update) {
            switch update {
            case .structure:
                itemsCount = presenter?.structure.count ?? 0
                itemCallsCount += 1
            case .availableActions:
                isAllactions = presenter?.availableActions == Presenter.Actions.all
                actionCallsCount += 1
            }

            currentExpectation?.fulfill()
        }
    #endif // USE_BINDING_FOR_PALIN_MVP
        func handle(action: Presenter.Action) {
            presenter?.handle(action: action)
        }

        private(set) var itemsCount: Int = 0
        private(set) var isAllactions = false
        private(set) var itemCallsCount = 0
        private(set) var actionCallsCount = 0

    #if USE_BINDING_FOR_PALIN_MVP
        var structureCancellable: BindCancellable?
        var actionsCancellable: BindCancellable?
    #endif // USE_BINDING_FOR_PALIN_MVP

        var currentExpectation: XCTestExpectation?
    }

    func baseMVVPProcessing(presenter: PresenterInterface, view: TestMVPViewInterface) throws {
        XCTAssertNotEqual(view.itemsCount, 0)
        XCTAssertFalse(view.isAllactions)

        let emptyItemsCount = presenter.structure.count
        XCTAssertEqual(view.itemsCount, emptyItemsCount)

        var step = 1
        view.handle(action: .changeSortingOrder(order: .none))
        XCTAssertEqual(view.itemCallsCount, step)
        XCTAssertEqual(view.actionCallsCount, step)
        XCTAssertFalse(view.isAllactions)
        XCTAssertEqual(view.itemsCount, emptyItemsCount)

        step += 1
        view.currentExpectation = XCTestExpectation(description: "Waiting for reload")
        view.handle(action: .reload)
        wait(for: [view.currentExpectation!], timeout: 2.0)

        XCTAssertEqual(view.itemCallsCount, step)
        XCTAssertEqual(view.actionCallsCount, step)
        XCTAssertTrue(view.isAllactions)
        XCTAssertNotEqual(view.itemsCount, emptyItemsCount)

        if presenter.sortingOrder != .none {
            step += 1
            view.currentExpectation = XCTestExpectation(description: "Waiting for reload")
            view.handle(action: .changeSortingOrder(order: .none)) // reset to .none
            wait(for: [view.currentExpectation!], timeout: 2.0)
        }

        let noneStructure = presenter.structure.map { $0.testDescription() }

        step += 1
        view.currentExpectation = XCTestExpectation(description: "Waiting for reload")
        view.handle(action: .changeSortingOrder(order: .ascending))
        wait(for: [view.currentExpectation!], timeout: 2.0)

        XCTAssertEqual(view.itemCallsCount, step)
        XCTAssertEqual(view.actionCallsCount, step)
        XCTAssertTrue(view.isAllactions)
        XCTAssertEqual(view.itemsCount, noneStructure.count)

        let ascendingStructure = presenter.structure.map { $0.testDescription() }
        XCTAssertNotEqual(ascendingStructure, noneStructure)

        step += 1
        view.currentExpectation = XCTestExpectation(description: "Waiting for reload")
        view.handle(action: .changeSortingOrder(order: .descending))
        wait(for: [view.currentExpectation!], timeout: 2.0)

        XCTAssertEqual(view.itemCallsCount, step)
        XCTAssertEqual(view.actionCallsCount, step)
        XCTAssertTrue(view.isAllactions)
        XCTAssertEqual(view.itemsCount, noneStructure.count)

        let descendingStructure = presenter.structure.map { $0.testDescription() }
        XCTAssertNotEqual(descendingStructure, noneStructure)
        XCTAssertNotEqual(descendingStructure, ascendingStructure)

        step += 1
        view.currentExpectation = XCTestExpectation(description: "Waiting for reload")
        view.handle(action: .clear)
        wait(for: [view.currentExpectation!], timeout: 2.0)

        XCTAssertEqual(view.itemCallsCount, step)
        XCTAssertEqual(view.actionCallsCount, step)
        XCTAssertFalse(view.isAllactions)
        XCTAssertNotEqual(view.itemsCount, noneStructure.count)
        XCTAssertEqual(view.itemsCount, emptyItemsCount)

    }
}

protocol TestMVPViewInterface: AnyObject {
    var itemsCount: Int { get }
    var isAllactions: Bool  { get }
    var itemCallsCount: Int  { get }
    var actionCallsCount: Int  { get }

    var currentExpectation: XCTestExpectation? { get set }

    func handle(action: Presenter.Action)
}
