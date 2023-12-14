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
    func testMVVMModelCombine() throws {
        let model = Model.MVVMCombine(with: modelDataProvider)

        var cancellable: AnyCancellable?
        try baseModelProcessing(model: model, ignoreFirst: true) { handler in
            cancellable = model.structure.sink {
                handler($0)
            }
        }

        cancellable?.cancel()
    }

    func testMVVMViewModelCombine() throws {
        let viewModelHolder = ViewModelHolder(ViewModel.MVVMCombine())

    #if USE_COMBINE_FOR_VIEW_ACTIONS
        let countOfInitCalls = 2
    #else
        let countOfInitCalls = 1
    #endif // USE_COMBINE_FOR_VIEW_ACTIONS

        var cancellable: AnyCancellable?
        try baseViewModelProcessing(viewModel: viewModelHolder, ignoreFirst: countOfInitCalls) { handler in
            cancellable = viewModelHolder.viewModel.structure.sink {
                handler($0)
            }
        }

        cancellable?.cancel()
    }
}
