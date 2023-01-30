//
//  Identifiable+Extensions.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 25/01/23.
//

import UIKit

extension Identifiable where Self: NSObject {
    /// Identifier for a nib class. Default to class name.
    public static var identifier: String {
        String(describing: self)
    }
    
    /// Create UINib for a nib class.
    public static func nib() -> UINib {
        return UINib(nibName: Self.identifier, bundle: nil)
    }
}
