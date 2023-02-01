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
    
    // MARK: Private Implementations
    
    private func setupGradientLayer() {
        gradientLayer.frame = bounds
        gradientLayer.colors = [gradientDarkColor, gradientLightColor, gradientDarkColor]
        layer.addSublayer(gradientLayer)
        layer.masksToBounds = true
    }

    internal func startAnimating() {
        setupGradientLayer()
        gradientLayer.add(animation, forKey: animation.keyPath)
    }
}
