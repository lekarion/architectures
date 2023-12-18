//
//  MVPViewController+Combine.swift
//  Architectures
//
//  Created by developer on 18.12.2023.
//

import Combine
import UIKit

protocol CombinePresenterViewInterface: PresenterViewInterface {
    var actionEvent: AnyPublisher<Presenter.Action, Never> { get }
}

class MVPCombineViewController: UIViewController, CombinePresenterViewInterface {
    var presenter: PresenterInterface?

    func handle(update: Presenter.Update) {
        fatalError("Not implemented")
    }

    var actionEvent: AnyPublisher<Presenter.Action, Never> { actionSubject.eraseToAnyPublisher() }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    private let actionSubject = PassthroughSubject<Presenter.Action, Never>()
}
