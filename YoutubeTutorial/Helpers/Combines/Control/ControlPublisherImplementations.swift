//
//  ControlPublisherImplementations.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 02/02/23.
//

import Combine
import UIKit

extension UIControl {
    internal func action(_ event: UIControl.Event = .touchUpInside) -> AnyPublisher<ControlPublisher.Output, ControlPublisher.Failure> {
        ControlPublisher(control: self, event: event)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
