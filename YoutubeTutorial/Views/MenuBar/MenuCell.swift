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
    
    // MARK: Properties
    
    override internal var isSelected: Bool {
        didSet {
            tabIcon.tintColor = isSelected ? .white : .redMenuIcon
        }
    }
    
    override internal var isHighlighted: Bool {
        didSet {
            tabIcon.tintColor = isHighlighted ? .white : .redMenuIcon
        }
    }
    
    // MARK: Layouts
    
    override internal func setupViews() {
        addSubview(tabIcon)
        
        NSLayoutConstraint.activate([
            tabIcon.centerXAnchor.constraint(equalTo: centerXAnchor),
            tabIcon.centerYAnchor.constraint(equalTo: centerYAnchor),
            tabIcon.widthAnchor.constraint(equalToConstant: 28),
            tabIcon.heightAnchor.constraint(equalToConstant: 28)
        ])
    }
    
    // MARK: Implementations
    
    internal func setupUI(menu: Menu) {
        tabIcon.image = menu.icon
    }
}
