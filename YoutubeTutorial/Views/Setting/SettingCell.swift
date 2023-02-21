//
//  SettingCell.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 02/02/23.
//

import UIKit

internal final class SettingCell: UICollectionViewCell {
    // MARK: UI Components
    
    private let settingIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.accessibilityIdentifier = "SettingCell.settingIcon"
        return imageView
    }()
    
    private let settingLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .preferredFont(forTextStyle: .callout)
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityIdentifier = "SettingCell.settingLabel"
        return label
    }()
    
    private let rootStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 16.0
        stack.alignment = .center
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.accessibilityIdentifier = "SettingCell.rootStack"
        return stack
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
    
    // MARK: Lifecycles
    
    internal func setupCell(setting: Setting, iconSize: CGFloat, inset: CGFloat) {
        settingLabel.text = setting.title
        settingIcon.image = setting.icon
        rootStack.addArrangedSubview(settingIcon)
        rootStack.addArrangedSubview(settingLabel)
        setupLayout(iconSize: iconSize, inset: inset)
    }
    
    // MARK: Layouts
    
    private func setupLayout(iconSize: CGFloat, inset: CGFloat) {
        contentView.addSubview(rootStack)
        NSLayoutConstraint.activate([
            rootStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            rootStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: inset),
            rootStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: inset),
            rootStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: inset)
        ])
        
        NSLayoutConstraint.activate([
            settingIcon.heightAnchor.constraint(equalToConstant: iconSize),
            settingIcon.widthAnchor.constraint(equalToConstant: iconSize)
        ])
    }
}
