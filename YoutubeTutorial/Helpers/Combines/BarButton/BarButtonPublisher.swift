//
//  BarButtonPublisher.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 02/02/23.
//

import Combine
import UIKit

internal class BarButtonPublisher: Publisher {
    typealias Output = Void
    typealias Failure = Never
    
    private let button: UIBarButtonItem
    
    internal init(button: UIBarButtonItem) {
        self.button = button
    }
    
    internal func receive<S>(subscriber: S) where S : Subscriber, ControlPublisher.Failure == S.Failure, ControlPublisher.Output == S.Input {
        let subscription = BarButtonSubscription(
            subscriber: subscriber,
            button: button
        )
        subscriber.receive(subscription: subscription)
    }
}
