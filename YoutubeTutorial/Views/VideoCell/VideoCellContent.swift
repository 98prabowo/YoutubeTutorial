//
//  VideoCellContent.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 01/02/23.
//

import Combine
import UIKit

internal final class VideoCellContent: UIView {
    // MARK: UI Components
    
    private let thumbnailImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.setContentHuggingPriority(.defaultLow, for: .vertical)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 22
        imageView.layer.masksToBounds = true
        imageView.setContentHuggingPriority(.required, for: .vertical)
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let title: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitle: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: Properties
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Life Cycles
    
    override internal init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required internal init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Layouts
    
    private func setupStackLayout() -> UIStackView {
        let titleStack = UIStackView(arrangedSubviews: [title, subtitle])
        titleStack.axis = .vertical
        titleStack.alignment = .leading
        titleStack.distribution = .fillProportionally
        titleStack.spacing = 4.0
        titleStack.translatesAutoresizingMaskIntoConstraints = false
        
        let profileStack = UIStackView(arrangedSubviews: [profileImage, titleStack])
        profileStack.axis = .horizontal
        profileStack.alignment = .center
        profileStack.distribution = .fill
        profileStack.spacing = 8.0
        profileStack.translatesAutoresizingMaskIntoConstraints = false
        
        let rootStack = UIStackView(arrangedSubviews: [thumbnailImage, profileStack])
        rootStack.axis = .vertical
        rootStack.alignment = .leading
        rootStack.distribution = .fillProportionally
        rootStack.spacing = 16.0
        rootStack.translatesAutoresizingMaskIntoConstraints = false
        
        return rootStack
    }
    
    private func setupViews() {
        backgroundColor = .white
        
        let rootView = setupStackLayout()
        addSubview(rootView)
        addSubview(separatorView)
        
        NSLayoutConstraint.activate([
            profileImage.widthAnchor.constraint(equalToConstant: 44),
            profileImage.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        NSLayoutConstraint.activate([
            rootView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            rootView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            rootView.topAnchor.constraint(equalTo: topAnchor, constant: 16)
        ])
        
        NSLayoutConstraint.activate([
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.topAnchor.constraint(equalTo: rootView.bottomAnchor, constant: 16),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    // MARK: Implementations
    
    internal func setupCell(
        title: String,
        subtitle: String,
        thumbnailImage: UIImage,
        profileImage: UIImage
    ) {
        self.title.text = title
        self.subtitle.text = subtitle
        self.thumbnailImage.image = thumbnailImage
        self.profileImage.image = profileImage
    }
}
