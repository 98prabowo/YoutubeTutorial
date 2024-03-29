//
//  UIView+Extensions.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 25/01/23.
//

import UIKit

extension UIView: Identifiable {
    /// Pin subview to it's superView programmatically with constraints.
    ///
    /// - Parameters:
    ///   - view: A `UIView` to add as a subview.
    ///   - padding: Padding value for every edges.
    ///   - size: Size value for view.
    ///   - options: Options describing the attribute and the direction of layout for all objects in the visual format string.
    ///   - metrics: A dictionary of constants that appear in the visual format string. The dictionary’s keys must be the string values used in the visual format string. Their values must be `NSNumber` objects..
    internal func pinSubview(
        _ view: UIView,
        _ padding: UIEdgeInsets = .zero,
        size: CGSize = .zero,
        options: NSLayoutConstraint.FormatOptions = [],
        metrics: [String : Any]? = nil
    ) {
        // Add view
        addSubview(view)
        
        // Prepare constraint format
        let widthFormat: String = size.width > 0 ? "(\(size.width))" : ""
        let heightFormat: String = size.height > 0 ? "(\(size.height))" : ""
        
        let leadingFormat: String = padding.left > 0 ? "-\(padding.left)-" : ""
        let trailingFormat: String = padding.right > 0 ? "-\(padding.right)-" : ""
        
        let topFormat: String = padding.top > 0 ? "-\(padding.top)-" : ""
        let bottomFormat: String = padding.bottom > 0 ? "-\(padding.bottom)-" : ""
        
        // Add constraint format
        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|\(leadingFormat)[v0\(widthFormat)]\(trailingFormat)|",
                options: options,
                metrics: metrics,
                views: ["v0": view]
            )
        )
        
        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|\(topFormat)[v0\(heightFormat)]\(bottomFormat)|",
                options: options,
                metrics: metrics,
                views: ["v0": view]
            )
        )
    }
    
    /// Round corner radius for for specific corners of `UIView`.
    ///
    /// - Parameters:
    ///   - corners: Add collection of specific corners that will be rounded.
    ///   - radius: Magnitude of radius for rounded corners.
    internal func roundSpecificCorners(_ corners: [UIRectCorner], radius: CGFloat) {
        self.layer.cornerRadius = radius
        var masked = CACornerMask()
        
        corners.forEach { corner in
            if corner.contains(.allCorners) || corner.contains(.topLeft) {
                masked.insert(CACornerMask.layerMinXMinYCorner)
            }
            
            if corner.contains(.allCorners) || corner.contains(.topRight) {
                masked.insert(CACornerMask.layerMaxXMinYCorner)
            }
            
            if corner.contains(.allCorners) || corner.contains(.bottomLeft) {
                masked.insert(CACornerMask.layerMinXMaxYCorner)
            }
            
            if corner.contains(.allCorners) || corner.contains(.bottomLeft) {
                masked.insert(CACornerMask.layerMaxXMaxYCorner)
            }
        }
        
        self.layer.maskedCorners = masked
    }
}
