//
//  Cancellable.swift
//  ImageLoader
//
//  Created by Taras Kreknin on 24.07.2020.
//  Copyright © 2020 SKGWAZAP. All rights reserved.
//

import Foundation

protocol Cancellable {
    func cancel()
}

struct Cancellables {
    
    private init() {}
    
    static func empty() -> Cancellable {
        return EmptyCancellable.empty
    }
}

private struct EmptyCancellable: Cancellable {
    
    static let empty: Cancellable = EmptyCancellable()
    
    private init() {}
    
    func cancel() {}
    
}

struct ActionCancellable: Cancellable {
    
    private let action: () -> Void
    
    func cancel() {
        action()
    }
    
    static func create(action: @escaping () -> Void) -> Cancellable {
        return ActionCancellable(action: action)
    }
    
}
