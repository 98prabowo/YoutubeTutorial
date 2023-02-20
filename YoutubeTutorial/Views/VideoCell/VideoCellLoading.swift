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
    
    // MARK: Layouts
    
    private func setupStackLayout() -> UIStackView {
        let titleStack = UIStackView(arrangedSubviews: [titleShimmer, subtitleShimmer])
        titleStack.axis = .vertical
        titleStack.alignment = .fill
        titleStack.distribution = .fillEqually
        titleStack.spacing = 4.0
        titleStack.translatesAutoresizingMaskIntoConstraints = false
        titleStack.accessibilityIdentifier = "VideoCellLoading.titleStack"
        
        let profileStack = UIStackView(arrangedSubviews: [profileImageShimmer, titleStack])
        profileStack.axis = .horizontal
        profileStack.alignment = .fill
        profileStack.distribution = .fill
        profileStack.spacing = 8.0
        profileStack.translatesAutoresizingMaskIntoConstraints = false
        profileStack.accessibilityIdentifier = "VideoCellLoading.profileStack"
        
        let rootStack = UIStackView(arrangedSubviews: [thumbnailImageShimmer, profileStack])
        rootStack.axis = .vertical
        rootStack.alignment = .fill
        rootStack.distribution = .fill
        rootStack.spacing = 16.0
        rootStack.translatesAutoresizingMaskIntoConstraints = false
        rootStack.accessibilityIdentifier = "VideoCellLoading.rootStack"
        
        return rootStack
    }
    
    private func setupViews() {
        backgroundColor = .white
        
        let rootView = setupStackLayout()
        addSubview(rootView)
        addSubview(separatorView)

        NSLayoutConstraint.activate([
            rootView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            rootView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            rootView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
        ])

        NSLayoutConstraint.activate([
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.topAnchor.constraint(equalTo: rootView.bottomAnchor, constant: 16),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
}
