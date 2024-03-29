//
//  BarButtonPublisherImplementations.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 02/02/23.
//

import Combine
import UIKit

extension UIBarButtonItem {
    internal func tap() -> AnyPublisher<Void, BarButtonPublisher.Failure> {
        BarButtonPublisher(button: self)
            .receive(on: DispatchQueue.main)
            .mapToVoid()
    }
}
