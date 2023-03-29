//
//  VideoDescriptionCell.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 28/03/23.
//

import Combine
import UIKit

internal final class VideoDescriptionCell: UICollectionViewCell {
    // MARK: UI Components
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title2)
        label.textColor = .label
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityIdentifier = "VideoDescriptionCell.titleLabel"
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption2)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityIdentifier = "VideoDescriptionCell.subtitle"
        return label
    }()
    
    private let profileImage: AsyncImageView = {
        let imageView = AsyncImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 22.0
        imageView.setContentHuggingPriority(.required, for: .vertical)
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.accessibilityIdentifier = "VideoDescriptionCell.profileImage"
        return imageView
    }()
    
    private var profileLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .label
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityIdentifier = "VideoDescriptionCell.titleLabel"
        return label
    }()
    
    private let profileStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 8.0
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.accessibilityIdentifier = "VideoDescriptionCell.profileStack"
        return stack
    }()
    
    // MARK: Properties
    
    private let profileImageSize: CGFloat = 44.0
    
    internal var cancellable: AnyCancellable?
    
    // MARK: Lifecycles
    
    override internal init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required internal init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Layouts
 
    private func setupViews() {
        backgroundColor = .white
        profileStack.addArrangedSubview(profileImage)
        profileStack.addArrangedSubview(profileLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(profileStack)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            profileImage.widthAnchor.constraint(equalToConstant: profileImageSize),
            profileImage.heightAnchor.constraint(equalToConstant: profileImageSize)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.0)
        ])
        
        let subtitleLabelTopConstraint = subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8.0)
        subtitleLabelTopConstraint.priority = .defaultHigh
        subtitleLabelTopConstraint.isActive = true
        subtitleLabelTopConstraint.identifier = "VideoDescriptionCell.subtitleLabelTopConstraint"
        
        NSLayoutConstraint.activate([
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0)
        ])
        
        let profileStackTopConstraint = profileStack.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16.0)
        profileStackTopConstraint.priority = .defaultHigh
        profileStackTopConstraint.isActive = true
        profileStackTopConstraint.identifier = "VideoDescriptionCell.profileStackTopConstraint"
        
        NSLayoutConstraint.activate([
            profileStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
            profileStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0),
            profileStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16.0)
        ])
    }
    
    override internal func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let targetSize: CGSize = CGSizeMake(layoutAttributes.frame.width, 0.0)
        layoutAttributes.frame.size = contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        return layoutAttributes
    }
    
    // MARK: Interfaces
    
    internal func setupCell(_ video: Video) {
        titleLabel.text = video.title
        subtitleLabel.text = video.subtitle
        profileImage.url = video.channel.profileImageName
        profileLabel.text = video.channel.name
        setupLayout()
    }
}
