//
//  VideoButton.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 10/03/23.
//

import UIKit

internal final class VideoButton: UIView {
    // MARK: UI Components
    
    private let image: UIImageView = {
        let img = UIImageView()
        img.tintColor = .white
        img.translatesAutoresizingMaskIntoConstraints = false
        img.accessibilityIdentifier = "SpeedButton.image"
        return img
    }()
    
    private let title: UILabel = {
        let text = UILabel()
        text.textColor = .white
        text.font = .preferredFont(forTextStyle: .callout)
        text.translatesAutoresizingMaskIntoConstraints = false
        text.accessibilityIdentifier = "SpeedButton.title"
        return text
    }()
    
    private let btnStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 4.0
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.accessibilityIdentifier = "LockButton.btnStack"
        return stack
    }()
    
    // MARK: Properties
    
    private let titleText: String
    
    // MARK: Lifecycles
    
    internal init(_ template: VideoButtonType) {
        titleText = template.title
        title.text = template.title
        image.image = template.image
        super.init(frame: .zero)
        setupInitialLayout()
        
    }
    
    required internal init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Layouts
    
    private func setupInitialLayout() {
        btnStack.addArrangedSubview(image)
        btnStack.addArrangedSubview(title)
        
        NSLayoutConstraint.activate([
            image.widthAnchor.constraint(equalToConstant: VideoButtonType.btnSize.width),
            image.heightAnchor.constraint(equalToConstant: VideoButtonType.btnSize.height)
        ])
        
        pinSubview(btnStack)
    }
}
