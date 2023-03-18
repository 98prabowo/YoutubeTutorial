//
//  ResolutionCell.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 17/03/23.
//

import Combine
import UIKit

internal final class ResolutionCell: UICollectionViewCell {
    // MARK: UI Components
    
    private let selectedIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.accessibilityIdentifier = "ResolutionCell.selectedIcon"
        return imageView
    }()
    
    private let resoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .preferredFont(forTextStyle: .callout)
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityIdentifier = "ResolutionCell.resoLabel"
        return label
    }()
    
    private let rootStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 16.0
        stack.alignment = .center
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.accessibilityIdentifier = "ResolutionCell.rootStack"
        return stack
    }()
    
    // MARK: Properties
    
    override internal var isSelected: Bool {
        didSet {
            selectedIcon.image = isSelected ? UIImage(systemName: "checkmark") : nil
        }
    }
    
    override internal var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? .secondaryLabel : .white
            selectedIcon.tintColor = isHighlighted ? .white : .secondaryLabel
            resoLabel.textColor = isHighlighted ? .white : .label
        }
    }
    
    internal var cancellable: AnyCancellable?
    
    // MARK: Lifecycles
    
    internal func setupCell(
        resolution: VideoDefinition,
        iconSize: CGFloat,
        verticalInset: CGFloat,
        insets: UIEdgeInsets
    ) {
        resoLabel.text = resolution.text
        rootStack.addArrangedSubview(selectedIcon)
        rootStack.addArrangedSubview(resoLabel)
        setupLayout(iconSize: iconSize, verticalInset: verticalInset, insets: insets)
    }
    
    // MARK: Layouts
    
    private func setupLayout(
        iconSize: CGFloat,
        verticalInset: CGFloat,
        insets: UIEdgeInsets
    ) {
        contentView.addSubview(rootStack)
        NSLayoutConstraint.activate([
            rootStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: insets.top),
            rootStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: insets.bottom),
            rootStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: verticalInset),
            rootStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -verticalInset)
        ])
        
        NSLayoutConstraint.activate([
            selectedIcon.heightAnchor.constraint(equalToConstant: iconSize),
            selectedIcon.widthAnchor.constraint(equalToConstant: iconSize)
        ])
    }
}
