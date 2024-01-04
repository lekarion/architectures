//
//  ModelTests+Combine.swift
//  ArchitecturesTests
//
//  Created by developer on 11.12.2023.
//

import Combine
import XCTest
@testable import Architectures

extension ArchitecturesTests {
    func testCombineModel() throws {
        let model = Model.CombineModel(with: modelDataProvider, imageProvider: imagesProvider)

        var cancellable: AnyCancellable?
        try baseModelProcessing(model: model) { handler in
            cancellable = model.structureBind.sink {
                handler($0)
            }
        }

        cancellable?.cancel()
    }

    func testMVVMViewModelCombine() throws {
        let viewModelHolder = ViewModelHolder(ViewModel.MVVMCombine(Self.identifier))

        var cancellable: AnyCancellable?
        try baseViewModelProcessing(viewModel: viewModelHolder) { handler in
            cancellable = viewModelHolder.viewModel.structureBind.sink {
                handler($0)
            }
        }

        cancellable?.cancel()
    }

    func testMVPPresenterCombine() throws {
        let model = Model.CombineModel(with: modelDataProvider, imageProvider: imagesProvider)
        let view = TestMVPViewCombine()
        let presenter = Presenter.MVPCombine("\(Self.identifier).mvp.combine")

        presenter.setup(with: model, view: view)
        XCTAssertNotNil(view.presenter)

        view.currentExpectation = XCTestExpectation(description: "Waiting for reload")
        view.viewDidLoad()
        wait(for: [view.currentExpectation!], timeout: 2.0)

        try baseMVVPProcessing(presenter: presenter, view: view)
    }
}

private extension ArchitecturesTests {
    class TestMVPViewCombine: TestMVPViewInterface, CombinePresenterViewInterface {
        var actionEvent: AnyPublisher<Presenter.Action, Never> { actionSubject.eraseToAnyPublisher() }

        weak var presenter: PresenterInterface? {
            get { combinePresenter }
            set {
                guard nil != newValue else {
                    combinePresenter = nil
                    return
                }

                guard let value = newValue as? CombinePresenterInterface else { return }
                combinePresenter = value
            }
        }

        func handle(update: Presenter.Update) {
            fatalError("Not implemented")
        }

        func viewDidLoad() {
            combinePresenter?.structureBind.sink { [weak self] in
                guard let self = self else { return }

                self.itemsCount = $0.count
                self.itemCallsCount += 1

                self.currentExpectation?.fulfill()
            }.store(in: &bag)

            combinePresenter?.availableActionsBind.sink { [weak self] in
                guard let self = self else { return }

                self.isAllactions = $0 == Presenter.Actions.all
                self.actionCallsCount += 1

                self.currentExpectation?.fulfill()
            }.store(in: &bag)

            combinePresenter?.viewDidLoad()
        }

        func handle(action: Presenter.Action) {
            actionSubject.send(action)
        }

        private(set) var itemsCount: Int = 0
        private(set) var isAllactions = false
        private(set) var itemCallsCount = 0
        private(set) var actionCallsCount = 0

        private var combinePresenter: CombinePresenterInterface?
        private let actionSubject = PassthroughSubject<Presenter.Action, Never>()
        private var bag = Set<AnyCancellable>()

        var currentExpectation: XCTestExpectation?
    }
}
