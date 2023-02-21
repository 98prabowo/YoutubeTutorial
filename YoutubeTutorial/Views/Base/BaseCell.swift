//
//  BaseCell.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 31/01/23.
//

import UIKit

internal class BaseCell: UICollectionViewCell {
    override internal init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    internal func setupViews() {}
    
    required internal init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
