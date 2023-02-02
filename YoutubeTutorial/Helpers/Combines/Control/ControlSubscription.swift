//
//  ControlSubscription.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 02/02/23.
//

import Combine
import UIKit

internal class ControlSubscription<S: Subscriber>: Subscription where S.Input == Void, S.Failure == Never {
    private var subscriber: S?
    private let control: UIControl
    
    internal init(subscriber: S, control: UIControl, event: UIControl.Event) {
        self.subscriber = subscriber
        self.control = control
        self.control.addTarget(self, action: #selector(handleEvent), for: event)
    }
    
    internal func request(_ demand: Subscribers.Demand) {}
    
    internal func cancel() {}
    
    @objc private func handleEvent(_ sender: UIControl) {
        _ = subscriber?.receive(())
    }
}
