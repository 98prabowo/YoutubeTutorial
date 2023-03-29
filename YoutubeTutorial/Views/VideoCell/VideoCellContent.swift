//
//  VideoCellContent.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 01/02/23.
//

import Combine
import UIKit

internal final class VideoCellContent: UICollectionViewCell {
    // MARK: UI Components
    
    private let thumbnailImage: AsyncImageView = {
        let imageView = AsyncImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.setContentHuggingPriority(.defaultLow, for: .vertical)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.accessibilityIdentifier = "VideoCellContent.thumbnailImage"
        return imageView
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemFill
        view.translatesAutoresizingMaskIntoConstraints = false
        view.accessibilityIdentifier = "VideoCellContent.separatorView"
        return view
    }()
    
    private let profileImage: AsyncImageView = {
        let imageView = AsyncImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 22.0
        imageView.setContentHuggingPriority(.required, for: .vertical)
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.accessibilityIdentifier = "VideoCellContent.profileImage"
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityIdentifier = "VideoCellContent.title"
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityIdentifier = "VideoCellContent.subtitle"
        return label
    }()
    
    private let titleStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.distribution = .fillProportionally
        stack.spacing = 4.0
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.accessibilityIdentifier = "VideoCellContent.titleStack"
        return stack
    }()
    
    private let profileStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 8.0
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.accessibilityIdentifier = "VideoCellContent.profileStack"
        return stack
    }()
    
    private let rootStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 16.0
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.accessibilityIdentifier = "VideoCellContent.rootStack"
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
        titleStack.addArrangedSubview(titleLabel)
        titleStack.addArrangedSubview(subtitleLabel)
        profileStack.addArrangedSubview(profileImage)
        profileStack.addArrangedSubview(titleStack)
        rootStack.addArrangedSubview(thumbnailImage)
        rootStack.addArrangedSubview(profileStack)
        contentView.addSubview(rootStack)
        contentView.addSubview(separatorView)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            profileImage.widthAnchor.constraint(equalToConstant: profileImageSize),
            profileImage.heightAnchor.constraint(equalToConstant: profileImageSize)
        ])
        
        let rootTrailingConstraint = rootStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0)
        rootTrailingConstraint.priority = .init(999.0)
        rootTrailingConstraint.isActive = true
        rootTrailingConstraint.identifier = "VideoCellContent.rootTrailingConstraint"
        
        NSLayoutConstraint.activate([
            rootStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
            rootStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.0)
        ])
        
        let spaceConstraint = separatorView.topAnchor.constraint(equalTo: rootStack.bottomAnchor, constant: 16.0)
        spaceConstraint.priority = .defaultHigh
        spaceConstraint.isActive = true
        spaceConstraint.identifier = "VideoCellContent.spaceConstraint"
        
        NSLayoutConstraint.activate([
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1.0)
        ])
    }
    
    override internal func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        // Use video pixel aspect ratio w: 16 h: 9 as thumbnail size
        let inset: CGFloat = 16.0
        let thumbnailHeight: CGFloat = (frame.width - inset - inset) * (9 / 16)
        let cellHeight: CGFloat = thumbnailHeight + inset + inset + 70.0
        let targetSize: CGSize = CGSizeMake(layoutAttributes.frame.width, cellHeight)
        layoutAttributes.frame.size = contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .required
        )
        return layoutAttributes
    }
    
    // MARK: Interfaces
    
    internal func setupCell(_ video: Video) {
        titleLabel.text = video.title
        subtitleLabel.text = video.subtitle
        thumbnailImage.url = video.thumbnailImageName
        profileImage.url = video.channel.profileImageName
        setupLayout()
    }
}
