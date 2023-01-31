//
//  MenuCell.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 31/01/23.
//

import UIKit

internal final class MenuCell: BaseCell {
    // MARK: UI Components
    
    private let tabIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .redMenuIcon
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override var isSelected: Bool {
        didSet {
            tabIcon.tintColor = isSelected ? .white : .redMenuIcon
        }
    }
    
    override internal func setupViews() {
        addSubview(tabIcon)
        
        NSLayoutConstraint.activate([
            tabIcon.centerXAnchor.constraint(equalTo: centerXAnchor),
            tabIcon.centerYAnchor.constraint(equalTo: centerYAnchor),
            tabIcon.widthAnchor.constraint(equalToConstant: 28),
            tabIcon.heightAnchor.constraint(equalToConstant: 28)
        ])
    }
    
    internal func setupUI(icon: UIImage?) {
        tabIcon.image = icon
    }
}
