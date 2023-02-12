//
//  Publisher+Extensions.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 06/02/23.
///Users/dimasprabowo/Documents/Projects/YoutubeTutorial/YoutubeTutorial/Helpers/NetworkManager/NetworkManager.swift

import Combine
import CoreGraphics

extension Publisher {
    internal func mapToVoid() -> AnyPublisher<Void, Self.Failure> {
        map { _ in return () }
            .eraseToAnyPublisher()
    }
    
    internal func defaultToZero<T>(_ transform: @escaping (Self.Output) -> T?) -> AnyPublisher<T, Self.Failure> where T : BinaryInteger {
        map { output in return transform(output) ?? 0 }
            .eraseToAnyPublisher()
    }
    
    internal func defaultToZero<T>(_ transform: @escaping (Self.Output) -> T?) -> AnyPublisher<T, Self.Failure> where T : BinaryFloatingPoint {
        map { output in return transform(output) ?? 0.0 }
            .eraseToAnyPublisher()
    }
}
