//
//  UICollectionView+Extensions.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 25/01/23.
//

import Foundation
import UIKit

extension UICollectionView {
    /// Shorter method caller for registering `UICollectionViewCell` in `UICollectionViewController`.
    ///
    /// - Parameters:
    ///   - forCell: A `UICollectionViewCell` class that need to implement identifier.
    internal func registerNib<T: UICollectionViewCell>(forCell: T.Type) {
        self.register(UINib(nibName: T.identifier, bundle: nil), forCellWithReuseIdentifier: T.identifier)
    }
    
    /// Shorter method caller for registering `UICollectionViewCell` in `UICollectionViewController`.
    ///
    /// - Parameters:
    ///   - forCell: A `UICollectionViewCell` class that need to implement identifier.
    internal func register<T: UICollectionViewCell>(forCell: T.Type) {
        self.register(T.self, forCellWithReuseIdentifier: T.identifier)
    }
    
    /// Dequeue reusable cell with shorter method caller for `UICollectionViewCell`. If error when dequeue will return instance of `UICollectionViewCell`.
    ///
    /// - Parameters:
    ///   - withCell: A `UICollectionViewCell` class that need to implement identifier.
    ///   - indexPath: An `IndexPath` from cellForItemAt method.
    internal func dequeueReusableCell<T: UICollectionViewCell> (withCell: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath) as? T else {
            return T()
        }
        return cell
    }
}
