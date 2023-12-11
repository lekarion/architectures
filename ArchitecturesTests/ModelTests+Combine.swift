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
        let viewModel = ViewModel.MVVMCombine()

        var cancellable: AnyCancellable?
        try baseViewModelProcessing(viewModel: viewModel, ignoreFirst: 2) { handler in
            cancellable = viewModel.structure.sink {
                handler($0)
            }
        }

        cancellable?.cancel()
    }
}