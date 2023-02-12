//
//  BarButtonSubscription.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 02/02/23.
//

import Combine
import UIKit

internal final class BarButtonSubscription<S: Subscriber>: Subscription where S.Input == Void, S.Failure == Never {
    private var subscriber: S?
    private let button: UIBarButtonItem
    
    internal init(subscriber: S, button: UIBarButtonItem) {
        self.subscriber = subscriber
        self.button = button
        self.button.target = self
        self.button.action = #selector(handleEvent)
    }
    
    internal func request(_ demand: Subscribers.Demand) {}
    
    internal func cancel() {
        subscriber = nil
    }
    
    @objc private func handleEvent(_ sender: UIControl) {
        _ = subscriber?.receive(())
    }
}
