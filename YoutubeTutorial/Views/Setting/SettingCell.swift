//
//  SettingCell.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 02/02/23.
//

import UIKit

internal final class SettingCell: BaseCell {
    // MARK: UI Components
    
    private let settingIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .scaleAspectFit
        imageView.setContentCompressionResistancePriority(.required, for: .vertical)
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let settingLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .preferredFont(forTextStyle: .callout)
        label.lineBreakMode = .byWordWrapping
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: Properties
    
    override internal var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? .secondaryLabel : .white
            settingIcon.tintColor = isSelected ? .white : .secondaryLabel
            settingLabel.textColor = isSelected ? .white : .label
        }
    }
    
    override internal var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? .secondaryLabel : .white
            settingIcon.tintColor = isHighlighted ? .white : .secondaryLabel
            settingLabel.textColor = isHighlighted ? .white : .label
        }
    }
    
    internal var setting: Setting? {
        didSet {
            settingLabel.text = setting?.title
            settingIcon.image = setting?.icon
        }
    }
    
    internal var iconSize: CGFloat = 0.0 {
        didSet {
            setupLayout()
        }
    }
    
    internal var verticalInset: CGFloat = 0.0 {
        didSet {
            setupLayout()
        }
    }
    
    // MARK: Layouts
    
    internal func setupLayout() {
        let rootStack = UIStackView(arrangedSubviews: [settingIcon, settingLabel])
        rootStack.axis = .horizontal
        rootStack.spacing = 16.0
        rootStack.alignment = .center
        rootStack.distribution = .fill
        rootStack.translatesAutoresizingMaskIntoConstraints = false
        
        pinSubview(rootStack, padding: UIEdgeInsets(inset: verticalInset))
        
        NSLayoutConstraint.activate([
            settingIcon.heightAnchor.constraint(equalToConstant: iconSize),
            settingIcon.widthAnchor.constraint(equalToConstant: iconSize)
        ])
    }
}
