//
//  GesturePublisher.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 02/02/23.
//

import Combine
import UIKit

internal final class GesturePublisher: Publisher {
    typealias Output = GestureType
    typealias Failure = Never
    
    private let view: UIView
    private let gestureType: GestureType
    
    internal init(_ view: UIView, gestureType: GestureType) {
        self.view = view
        self.gestureType = gestureType
    }
    
    internal func receive<S>(subscriber: S) where S : Subscriber, GesturePublisher.Failure == S.Failure, GesturePublisher.Output == S.Input {
        let subscription = GestureSubscription(
            subscriber: subscriber,
            view: view,
            gestureType: gestureType
        )
        subscriber.receive(subscription: subscription)
    }
}
