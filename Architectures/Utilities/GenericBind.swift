//
//  GenericBind.swift
//  Architectures
//
//  Created by developer on 30.11.2023.
//

import Foundation

protocol BindInterface: AnyObject {
    associatedtype ValueType
    associatedtype ChangeHandler

    var value: ValueType { get set }
    func bind(_ handler: ChangeHandler?) -> BindCancellable
}

protocol BindCancellable: AnyObject {
    func cancel()
}

// MARK: -
class GenericBind<T>: BindInterface {
    typealias Handler = (T) -> Void

    init(value: T) {
        self.value = value
    }

    func bind(_ handler: Handler?) -> BindCancellable {
        let holder = BindHolder(handler, bind: self)
        holders.append(GenericRefHolder(holder))

        return holder
    }

    var value: T {
        didSet {
            holders.forEach { $0.object?.perform { $0(value) } }
        }
    }

    private var holders = [GenericRefHolder<BindHolder>]()
}

private extension GenericBind {
    class BindHolder: BindCancellable, RefHolderIdentification {
        init(_ handler: Handler?, bind: GenericBind<T>) {
            self.handler = handler
            self.bind = bind
        }

        deinit {
            bind?.cancel(self)
        }

        func cancel() {
            bind?.cancel(self)
            bind = nil

            handler = nil
        }

        func perform(_ action: (Handler) -> Void) {
            guard let handler = self.handler else { return }
            action(handler)
        }

        let identifier = UUID().uuidString

        private var handler: Handler?
        private weak var bind: GenericBind<T>?
    }

    func cancel(_ holder: BindHolder) {
        guard let index = holders.firstIndex(where: { $0.contains(holder) }) else { return }
        holders.remove(at: index)
    }
}

extension GenericBind.BindHolder: Hashable {
    static func == (lhs: GenericBind.BindHolder, rhs: GenericBind.BindHolder) -> Bool {
        lhs.identifier == rhs.identifier
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

extension GenericBind { // Tests & Utilities
    var isInUse: Bool { !holders.isEmpty }
}

// MARK: -
protocol RefHolderIdentification: AnyObject {
    associatedtype Identifier: Equatable
    var identifier: Identifier { get }
}

class GenericRefHolder<T: RefHolderIdentification> {
    init(_ object: T) {
        self.object = object
        self.identifier = object.identifier
    }

    func contains(_ object: T) -> Bool {
        (self.object == nil) ? identifier == object.identifier : self.object?.identifier == object.identifier
    }

    private(set) weak var object: T?
    private let identifier: T.Identifier
}
