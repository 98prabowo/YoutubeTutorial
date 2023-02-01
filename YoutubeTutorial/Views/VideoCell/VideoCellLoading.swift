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
        shimmer.setContentHuggingPriority(.defaultLow, for: .vertical)
        shimmer.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        shimmer.translatesAutoresizingMaskIntoConstraints = false
        return shimmer
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let profileImageShimmer: ShimmerView = {
        let shimmer = ShimmerView()
        shimmer.layer.cornerRadius = 22
        shimmer.setContentHuggingPriority(.required, for: .vertical)
        shimmer.setContentHuggingPriority(.required, for: .horizontal)
        shimmer.translatesAutoresizingMaskIntoConstraints = false
        return shimmer
    }()

    private let titleShimmer: ShimmerView = {
        let shimmer = ShimmerView()
        shimmer.setContentHuggingPriority(.defaultLow, for: .vertical)
        shimmer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        shimmer.setContentCompressionResistancePriority(.required, for: .vertical)
        shimmer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        shimmer.translatesAutoresizingMaskIntoConstraints = false
        return shimmer
    }()

    private let subtitleShimmer: ShimmerView = {
        let shimmer = ShimmerView()
        shimmer.setContentCompressionResistancePriority(.required, for: .vertical)
        shimmer.translatesAutoresizingMaskIntoConstraints = false
        return shimmer
    }()
    
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
        let titleStack = UIStackView(arrangedSubviews: [titleShimmer, subtitleShimmer])
        titleStack.axis = .vertical
        titleStack.alignment = .fill
        titleStack.distribution = .fillEqually
        titleStack.spacing = 4.0
        titleStack.translatesAutoresizingMaskIntoConstraints = false
        
        let profileStack = UIStackView(arrangedSubviews: [profileImageShimmer, titleStack])
        profileStack.axis = .horizontal
        profileStack.alignment = .fill
        profileStack.distribution = .fill
        profileStack.spacing = 8.0
        profileStack.translatesAutoresizingMaskIntoConstraints = false
        
        let rootStack = UIStackView(arrangedSubviews: [thumbnailImageShimmer, profileStack])
        rootStack.axis = .vertical
        rootStack.alignment = .fill
        rootStack.distribution = .fill
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
            profileImageShimmer.widthAnchor.constraint(equalToConstant: 44),
            profileImageShimmer.heightAnchor.constraint(equalToConstant: 44)
        ])
        
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
    
    // MARK: Implementations
    
    internal func starAnimating() {
        thumbnailImageShimmer.startAnimating()
        titleShimmer.startAnimating()
        subtitleShimmer.startAnimating()
        profileImageShimmer.startAnimating()
    }
}
