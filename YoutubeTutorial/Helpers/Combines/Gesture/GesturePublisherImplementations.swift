//
//  GesturePublisherImplementations.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 02/02/23.
//

import Combine
import UIKit

extension UIView {
    internal func tap(
        numberOfTapsRequired: Int = 1,
        numberOfTouchesRequired: Int = 1
    ) -> AnyPublisher<Void, GesturePublisher.Failure> {
        let gesture = UITapGestureRecognizer()
        gesture.numberOfTapsRequired = numberOfTapsRequired
        gesture.numberOfTouchesRequired = numberOfTouchesRequired
        return GesturePublisher(self, gestureType: .tap(gesture))
            .receive(on: DispatchQueue.main)
            .mapToVoid()
    }
    
    internal func swipe(
        direction: UISwipeGestureRecognizer.Direction,
        numberOfTouchesRequired: Int = 1
    ) -> AnyPublisher<GesturePublisher.Output, GesturePublisher.Failure> {
        let gesture = UISwipeGestureRecognizer()
        gesture.direction = direction
        gesture.numberOfTouchesRequired = numberOfTouchesRequired
        return GesturePublisher(self, gestureType: .swipe(gesture))
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    internal func longPress(
        minimumPressDuration: TimeInterval = 0.5,
        allowableMovement: CGFloat = 10.0,
        numberOfTapsRequired: Int = 1,
        numberOfTouchesRequired: Int = 1
    ) -> AnyPublisher<GesturePublisher.Output, GesturePublisher.Failure> {
        let gesture = UILongPressGestureRecognizer()
        gesture.minimumPressDuration = minimumPressDuration
        gesture.allowableMovement = allowableMovement
        gesture.numberOfTapsRequired = numberOfTapsRequired
        gesture.numberOfTouchesRequired = numberOfTouchesRequired
        return GesturePublisher(self, gestureType: .longPress(gesture))
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    internal func pan(
        minimumNumberOfTouches: Int = 1,
        maximumNumberOfTouches: Int = Int(UInt.max)
    ) -> AnyPublisher<GesturePublisher.Output, GesturePublisher.Failure> {
        let gesture = UIPanGestureRecognizer()
        gesture.minimumNumberOfTouches = minimumNumberOfTouches
        gesture.maximumNumberOfTouches = maximumNumberOfTouches
        return GesturePublisher(self, gestureType: .pan(gesture))
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    internal func pinch() -> AnyPublisher<GesturePublisher.Output, GesturePublisher.Failure> {
        GesturePublisher(self, gestureType: .pinch())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    internal func edge(
        minimumNumberOfTouches: Int = 1,
        maximumNumberOfTouches: Int = Int(UInt.max)
    ) -> AnyPublisher<GesturePublisher.Output, GesturePublisher.Failure> {
        let gesture = UIScreenEdgePanGestureRecognizer()
        gesture.minimumNumberOfTouches = minimumNumberOfTouches
        gesture.maximumNumberOfTouches = maximumNumberOfTouches
        return GesturePublisher(self, gestureType: .edge(gesture))
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
