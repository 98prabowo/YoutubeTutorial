//
//  UIColor+Extensions.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 31/01/23.
//

import UIKit

extension UIColor {
    convenience init(red: CGFloat, green: CGFloat, blue: CGFloat) {
        self.init(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
}
