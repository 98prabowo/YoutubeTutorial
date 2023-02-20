//
//  UIColor+Extensions.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 31/01/23.
//

import UIKit

extension UIColor {
    /// Shorter initializer for `UIColor` that will automatically divide all rgb value into 255.
    ///
    /// - Parameters:
    ///   - red: red color value.
    ///   - green: green color value.
    ///   - blue: blue color value.
    internal convenience init(red: CGFloat, green: CGFloat, blue: CGFloat) {
        self.init(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
    /// Color code for youtube tutorial navigation bar.
    internal static var redNavBar: UIColor = UIColor(red: 230, green: 32, blue: 31)
    
    /// Color code for youtube tutorial menu bar icon.
    internal static var redMenuIcon: UIColor = UIColor(red: 91, green: 14, blue: 13)
    
    /// Color code for youtube tutorial video controller background.
    internal static var videoControllerBackground: UIColor = UIColor(white: 0.0, alpha: 0.5)
}
