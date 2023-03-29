//
//  UIEdgeInsets+Extensions.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 25/01/23.
//

import UIKit

extension UIEdgeInsets {
    /// Edge type to help padding constractor
    internal enum Edge {
        case horizontal
        case vertical
        case left
        case right
        case top
        case bottom
    }
    
    /// Shorter initializer for `UIEdgeInsets` that will instantiate with same value for all edges.
    ///
    /// - Parameters:
    ///   - inset: An inset value.
    internal init(inset: CGFloat) {
        self.init(top: inset, left: inset, bottom: inset, right: inset)
    }
    
    /// Shorter initializer for `UIEdgeInsets` that will instantiate for specific edge.
    ///
    /// - Parameters:
    ///   - inset: A value to determine how padding the view you need.
    ///   - edge: To determinse specific edge for `UIEdgeInset` creation.
    internal static func padding(_ inset: CGFloat, _ edge: Edge? = nil) -> UIEdgeInsets {
        switch edge {
        case .horizontal:
            return UIEdgeInsets(top: 0.0, left: inset, bottom: 0.0, right: inset)
        case .vertical:
            return UIEdgeInsets(top: inset, left: 0.0, bottom: inset, right: 0.0)
        case .left:
            return UIEdgeInsets(top: 0.0, left: inset, bottom: 0.0, right: 0.0)
        case .right:
            return UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: inset)
        case .top:
            return UIEdgeInsets(top: inset, left: 0.0, bottom: 0.0, right: 0.0)
        case .bottom:
            return UIEdgeInsets(top: 0.0, left: 0.0, bottom: inset, right: 0.0)
        case .none:
            return UIEdgeInsets(inset: inset)
        }
    }
    
    /// Shorter method to handle replacement for `UIEdgeInsets`.
    ///
    /// - Parameters:
    ///   - inset: A value to determine how padding the view you need.
    ///   - edge: To determinse specific edge for `UIEdgeInset` creation.
    internal func replace(_ inset: CGFloat, _ edge: Edge? = nil) -> UIEdgeInsets {
        switch edge {
        case .horizontal:
            return UIEdgeInsets(
                top: self.top,
                left: inset,
                bottom: self.bottom,
                right: inset
            )
        case .vertical:
            return UIEdgeInsets(
                top: inset,
                left: self.left,
                bottom: inset,
                right: self.right
            )
        case .left:
            return UIEdgeInsets(
                top: self.top,
                left: inset,
                bottom: self.bottom,
                right: self.right
            )
        case .right:
            return UIEdgeInsets(
                top: self.top,
                left: self.left,
                bottom: self.bottom,
                right: inset
            )
        case .top:
            return UIEdgeInsets(
                top: inset,
                left: self.left,
                bottom: self.bottom,
                right: self.right
            )
        case .bottom:
            return UIEdgeInsets(
                top: self.top,
                left: self.left,
                bottom: inset,
                right: self.right
            )
        case .none:
            return UIEdgeInsets(
                top: inset,
                left: inset,
                bottom: inset,
                right: inset
            )
        }
    }
    
    /// Shorter method to handle addition for `UIEdgeInsets`.
    ///
    /// - Parameters:
    ///   - inset: A value to determine how padding the view you need.
    ///   - edge: To determinse specific edge for `UIEdgeInset` creation.
    internal func add(_ inset: CGFloat, _ edge: Edge? = nil) -> UIEdgeInsets {
        switch edge {
        case .horizontal:
            return UIEdgeInsets(
                top: self.top,
                left: self.left + inset,
                bottom: self.bottom,
                right: self.right + inset
            )
        case .vertical:
            return UIEdgeInsets(
                top: self.top + inset,
                left: self.left,
                bottom: self.bottom + inset,
                right: self.right
            )
        case .left:
            return UIEdgeInsets(
                top: self.top,
                left: self.left + inset,
                bottom: self.bottom,
                right: self.right
            )
        case .right:
            return UIEdgeInsets(
                top: self.top,
                left: self.left,
                bottom: self.bottom,
                right: self.right + inset
            )
        case .top:
            return UIEdgeInsets(
                top: self.top + inset,
                left: self.left,
                bottom: self.bottom,
                right: self.right
            )
        case .bottom:
            return UIEdgeInsets(
                top: self.top,
                left: self.left,
                bottom: self.bottom + inset,
                right: self.right
            )
        case .none:
            return UIEdgeInsets(
                top: self.top + inset,
                left: self.left + inset,
                bottom: self.bottom + inset,
                right: self.right + inset
            )
        }
    }
    
    /// Shorter method to handle substraction for `UIEdgeInsets`.
    ///
    /// - Parameters:
    ///   - inset: A value to determine how padding the view you need.
    ///   - edge: To determinse specific edge for `UIEdgeInset` creation.
    ///   - lowest: The bottom limit of substraction operator, if below this limit will return limit value.
    internal func substract(_ inset: CGFloat, _ edge: Edge? = nil, lowest limit: CGFloat? = nil) -> UIEdgeInsets {
        switch edge {
        case .horizontal:
            let left: CGFloat
            let right: CGFloat
            
            if let limit {
                left = limitedSubstraction(self.left, inset, limit: limit)
                right = limitedSubstraction(self.right, inset, limit: limit)
            } else {
                left = self.left - inset
                right = self.right - inset
            }
            
            return UIEdgeInsets(
                top: self.top,
                left: left,
                bottom: self.bottom,
                right: right
            )
            
        case .vertical:
            let top: CGFloat
            let bottom: CGFloat
            
            if let limit {
                top = limitedSubstraction(self.top, inset, limit: limit)
                bottom = limitedSubstraction(self.bottom, inset, limit: limit)
            } else {
                top = self.top - inset
                bottom = self.bottom - inset
            }
            
            return UIEdgeInsets(
                top: top,
                left: self.left,
                bottom: bottom,
                right: self.right
            )
            
        case .top:
            let top: CGFloat
            
            if let limit {
                top = limitedSubstraction(self.top, inset, limit: limit)
            } else {
                top = self.top - inset
            }
            
            return UIEdgeInsets(
                top: top,
                left: self.left,
                bottom: self.bottom,
                right: self.right
            )
            
        case .left:
            let left: CGFloat
            
            if let limit {
                left = limitedSubstraction(self.left, inset, limit: limit)
            } else {
                left = self.left - inset
            }
            
            return UIEdgeInsets(
                top: self.top,
                left: left,
                bottom: self.bottom,
                right: self.right
            )
            
        case .bottom:
            let bottom: CGFloat
            
            if let limit {
                bottom = limitedSubstraction(self.bottom, inset, limit: limit)
            } else {
                bottom = self.bottom - inset
            }
            
            return UIEdgeInsets(
                top: self.top,
                left: self.left,
                bottom: bottom,
                right: self.right
            )
            
        case .right:
            let right: CGFloat
            
            if let limit {
                right = limitedSubstraction(self.right, inset, limit: limit)
            } else {
                right = self.right - inset
            }
            
            return UIEdgeInsets(
                top: self.top,
                left: self.left,
                bottom: self.bottom,
                right: right
            )
            
        case .none:
            let top: CGFloat
            let left: CGFloat
            let bottom: CGFloat
            let right: CGFloat
            
            if let limit {
                top = limitedSubstraction(self.top, inset, limit: limit)
                left = limitedSubstraction(self.left, inset, limit: limit)
                bottom = limitedSubstraction(self.bottom, inset, limit: limit)
                right = limitedSubstraction(self.right, inset, limit: limit)
            } else {
                top = self.top - inset
                left = self.left - inset
                bottom = self.bottom - inset
                right = self.right - inset
            }
            
            return UIEdgeInsets(
                top: top,
                left: left,
                bottom: bottom,
                right: right
            )
        }
    }
    
    private func limitedSubstraction(_ lhs: CGFloat, _ rhs: CGFloat, limit: CGFloat) -> CGFloat {
        if lhs - rhs < limit {
            return limit
        } else {
            return lhs - rhs
        }
    }
}

extension Optional where Wrapped == UIEdgeInsets {
    /// Return zero for all edges if `UIEdgeInsets` is nil.
    internal var zeroIfNil: UIEdgeInsets {
        return self ?? .zero
    }
}
