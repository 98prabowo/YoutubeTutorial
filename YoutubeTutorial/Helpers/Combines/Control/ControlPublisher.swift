//
//  ControlPublisher.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 02/02/23.
//

import Combine
import UIKit

internal final class ControlPublisher: Publisher {
    typealias Output = Void
    typealias Failure = Never
    
    private let control: UIControl
    private let event: UIControl.Event
    
    internal init(control: UIControl, event: UIControl.Event) {
        self.control = control
        self.event = event
    }
    
    internal func receive<S>(subscriber: S) where S : Subscriber, ControlPublisher.Failure == S.Failure, ControlPublisher.Output == S.Input {
        let subscription = ControlSubscription(
            subscriber: subscriber,
            control: control,
            event: event
        )
        subscriber.receive(subscription: subscription)
    }
}
