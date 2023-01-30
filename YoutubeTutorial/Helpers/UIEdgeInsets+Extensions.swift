//
//  UIEdgeInsets+Extensions.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 25/01/23.
//

import UIKit

extension UIEdgeInsets {
    /// Shorter initializer for `UIEdgeInsets` that will instantiate with same value for all edges.
    ///
    /// - Parameters:
    ///   - inset: An inset value.
    internal init(inset: CGFloat) {
        self.init(top: inset, left: inset, bottom: inset, right: inset)
    }
}
