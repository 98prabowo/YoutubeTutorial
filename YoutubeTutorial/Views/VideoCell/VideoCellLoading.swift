//
//  VideoCellLoading.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 01/02/23.
//

import UIKit

internal final class VideoCellLoading: UIView {
    // MARK: UI Components
    
    private let thumbnailImageShimmer: ShimmerView = {
        let shimmer = ShimmerView()
        shimmer.size = CGSizeMake(400, 400)
        shimmer.setContentHuggingPriority(.defaultLow, for: .vertical)
        shimmer.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        shimmer.translatesAutoresizingMaskIntoConstraints = false
        shimmer.accessibilityIdentifier = "VideoCellLoading.thumbnailImageShimmer"
        return shimmer
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemFill
        view.translatesAutoresizingMaskIntoConstraints = false
        view.accessibilityIdentifier = "VideoCellLoading.separatorView"
        return view
    }()
    
    private let profileImageShimmer: ShimmerView = {
        let shimmer = ShimmerView()
        shimmer.size = CGSizeMake(44, 44)
        shimmer.cornerRadius = 22
        shimmer.setContentHuggingPriority(.required, for: .vertical)
        shimmer.setContentHuggingPriority(.required, for: .horizontal)
        shimmer.translatesAutoresizingMaskIntoConstraints = false
        shimmer.accessibilityIdentifier = "VideoCellLoading.profileImageShimmer"
        return shimmer
    }()

    private let titleShimmer: ShimmerView = {
        let shimmer = ShimmerView()
        shimmer.size = CGSizeMake(300, 20)
        shimmer.setContentHuggingPriority(.defaultLow, for: .vertical)
        shimmer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        shimmer.setContentCompressionResistancePriority(.required, for: .vertical)
        shimmer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        shimmer.translatesAutoresizingMaskIntoConstraints = false
        shimmer.accessibilityIdentifier = "VideoCellLoading.titleShimmer"
        return shimmer
    }()

    private let subtitleShimmer: ShimmerView = {
        let shimmer = ShimmerView()
        shimmer.size = CGSizeMake(300, 20)
        shimmer.setContentCompressionResistancePriority(.required, for: .vertical)
        shimmer.translatesAutoresizingMaskIntoConstraints = false
        shimmer.accessibilityIdentifier = "VideoCellLoading.subtitleShimmer"
        return shimmer
    }()
    
    // MARK: Lifecycles
    
    override internal init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required internal init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let titleStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 4.0
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.accessibilityIdentifier = "VideoCellLoading.titleStack"
        return stack
    }()
    
    private let profileStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 8.0
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.accessibilityIdentifier = "VideoCellLoading.profileStack"
        return stack
    }()
    
    private let rootStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 16.0
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.accessibilityIdentifier = "VideoCellLoading.rootStack"
        return stack
    }()
    
    // MARK: Layouts
    
    private func setupViews() {
        backgroundColor = .white
        titleStack.addArrangedSubview(titleShimmer)
        titleStack.addArrangedSubview(subtitleShimmer)
        profileStack.addArrangedSubview(profileImageShimmer)
        profileStack.addArrangedSubview(titleStack)
        rootStack.addArrangedSubview(thumbnailImageShimmer)
        rootStack.addArrangedSubview(profileStack)
        addSubview(rootStack)
        addSubview(separatorView)
        setupLayout()
    }
    
    private func setupLayout() {
        let rootTrailingConstraint = rootStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0)
        rootTrailingConstraint.priority = .init(999)
        rootTrailingConstraint.isActive = true
        rootTrailingConstraint.identifier = "VideoCellLoading.setupLayout"
        
        NSLayoutConstraint.activate([
            rootStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            rootStack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
        ])
        
        let spaceConstraint = separatorView.topAnchor.constraint(equalTo: rootStack.bottomAnchor, constant: 16.0)
        spaceConstraint.priority = .defaultHigh
        spaceConstraint.isActive = true
        spaceConstraint.identifier = "VideoCellLoading.spaceConstraint"

        NSLayoutConstraint.activate([
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
}
