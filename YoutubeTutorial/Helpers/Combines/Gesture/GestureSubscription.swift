//
//  GestureSubscription.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 02/02/23.
//

import Combine
import UIKit

internal final class GestureSubscription<SubscriberType: Subscriber>: Subscription where SubscriberType.Input == GestureType, SubscriberType.Failure == Never {
    private var subscriber: SubscriberType?
    private let gestureType: GestureType
    private let view: UIView
    
    internal init(subscriber: SubscriberType, view: UIView, gestureType: GestureType) {
        self.subscriber = subscriber
        self.gestureType = gestureType
        self.view = view
        configureGesture(gestureType)
    }
    
    private func configureGesture(_ gestureType: GestureType) {
        let gesture = gestureType.get()
        gesture.addTarget(self, action: #selector(handleEvent))
        view.addGestureRecognizer(gesture)
    }
    
    internal func request(_ demand: Subscribers.Demand) {}
    
    internal func cancel() {
        subscriber = nil
    }
    
    @objc private func handleEvent(_ sender: UIGestureRecognizer) {
        _ = subscriber?.receive(gestureType)
    }
}
