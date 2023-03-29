//
//  UICollectionViewFlowLayout+Extensions.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 28/03/23.
//

import UIKit

internal final class VideoFlowLayout: UICollectionViewFlowLayout {
    override internal func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributesObjects = super.layoutAttributesForElements(in: rect)?.map { $0.copy() } as? [UICollectionViewLayoutAttributes]
        layoutAttributesObjects?.forEach {
            if $0.representedElementCategory == .cell {
                if let newFrame = layoutAttributesForItem(at: $0.indexPath)?.frame {
                    $0.frame = newFrame
                }
            }
        }
        return layoutAttributesObjects
    }
    
    override internal func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let collectionView = collectionView,
              let layoutAttributes = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes else {
            return nil
        }

        layoutAttributes.frame.origin.x = sectionInset.left
        layoutAttributes.frame.size.width = collectionView.safeAreaLayoutGuide.layoutFrame.width - sectionInset.left - sectionInset.right
        return layoutAttributes
    }
}
