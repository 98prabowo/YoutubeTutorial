//
//  CancelOperator.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 22/02/23.
//

import Combine

extension Set where Element == AnyCancellable {
    internal mutating func cancelAll() {
        forEach { $0.cancel() }
        removeAll()
    }
}
