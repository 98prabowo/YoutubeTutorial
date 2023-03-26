//
//  UIStackView+Extensions.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 27/03/23.
//

import UIKit

extension UIStackView {
    internal func removeAllArrangedSubviews() {
        arrangedSubviews.forEach {
            self.removeArrangedSubview($0)
            NSLayoutConstraint.deactivate($0.constraints)
            $0.removeFromSuperview()
        }
    }
}
