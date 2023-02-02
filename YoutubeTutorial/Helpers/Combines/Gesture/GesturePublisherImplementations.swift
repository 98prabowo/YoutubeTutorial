//
//  GesturePublisherImplementations.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 02/02/23.
//

import Combine
import UIKit

extension UIView {
    internal func tap() -> Publishers.ReceiveOn<GesturePublisher, DispatchQueue> {
        GesturePublisher(self, gestureType: .tap())
            .receive(on: DispatchQueue.main)
    }
    
    internal func swipe() -> Publishers.ReceiveOn<GesturePublisher, DispatchQueue> {
        GesturePublisher(self, gestureType: .swipe())
            .receive(on: DispatchQueue.main)
    }
    
    internal func longPress() -> Publishers.ReceiveOn<GesturePublisher, DispatchQueue> {
        GesturePublisher(self, gestureType: .longPress())
            .receive(on: DispatchQueue.main)
    }
    
    internal func pan() -> Publishers.ReceiveOn<GesturePublisher, DispatchQueue> {
        GesturePublisher(self, gestureType: .pan())
            .receive(on: DispatchQueue.main)
    }
    
    internal func pinch() -> Publishers.ReceiveOn<GesturePublisher, DispatchQueue> {
        GesturePublisher(self, gestureType: .pinch())
            .receive(on: DispatchQueue.main)
    }
    
    internal func edge() -> Publishers.ReceiveOn<GesturePublisher, DispatchQueue> {
        GesturePublisher(self, gestureType: .edge())
            .receive(on: DispatchQueue.main)
    }
}
