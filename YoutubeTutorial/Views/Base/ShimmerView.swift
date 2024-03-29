//
//  ShimmerView.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 01/02/23.
//

import UIKit

internal class ShimmerView: UIView {
    // MARK: UI Components
    
    private let gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = CGPointMake(0.0, 1.0)
        gradientLayer.endPoint = CGPointMake(1.0, 1.0)
        gradientLayer.locations = [0.0, 0.5, 1.0]
        return gradientLayer
    }()

    private let animation: CABasicAnimation = {
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.repeatCount = .infinity
        animation.duration = 0.9
        return animation
    }()
    
    // MARK: Properties
    
    private let gradientDarkColor: CGColor = UIColor(white: 0.75, alpha: 1).cgColor
    
    private let gradientLightColor: CGColor = UIColor(white: 0.85, alpha: 1).cgColor
    
    internal var size: CGSize = .zero {
        didSet {
            startAnimating()
        }
    }
    
    internal var cornerRadius: CGFloat = .zero {
        didSet {
            startAnimating()
        }
    }
    
    // MARK: Layouts
    
    private func setupLayout() {
        let widthAnchor = widthAnchor.constraint(equalToConstant: size.width)
        widthAnchor.priority = .defaultLow
        widthAnchor.isActive = true
        
        let heightAnchor = heightAnchor.constraint(equalToConstant: size.height)
        heightAnchor.priority = .defaultLow
        heightAnchor.isActive = true
    }
    
    // MARK: Private Implementations
    
    private func setupGradientLayer() {
        let updateBounds = CGRectMake(
            frame.origin.x,
            frame.origin.y,
            size.width,
            size.height
        )
        
        gradientLayer.frame = updateBounds
        gradientLayer.cornerRadius = cornerRadius
        gradientLayer.colors = [gradientDarkColor, gradientLightColor, gradientDarkColor]
        layer.addSublayer(gradientLayer)
        layer.masksToBounds = true
    }

    private func startAnimating() {
        setupGradientLayer()
        gradientLayer.add(animation, forKey: animation.keyPath)
        setupLayout()
    }
}
