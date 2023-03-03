//
//  UINavigationController+Extensions.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 03/03/23.
//

import UIKit

extension UINavigationController {
    open override var childForStatusBarStyle: UIViewController? {
        return self.topViewController
    }

    open override var childForStatusBarHidden: UIViewController? {
        return self.topViewController
    }
}
