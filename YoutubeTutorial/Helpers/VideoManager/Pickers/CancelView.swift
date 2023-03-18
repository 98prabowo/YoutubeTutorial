//
//  CancelView.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 17/03/23.
//

import UIKit

internal final class CancelView: UIView {
    // MARK: UI Components
    
    private let cancelLabel: UILabel = {
        let label = UILabel()
        label.text = "Cancel"
        label.textColor = .label
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityIdentifier = "PlaybackResolutionView.cancelLabel"
        return label
    }()
    
    private let cancelImg: UIImageView = {
        let img = UIImage(systemName: "xmark")
        let imgView = UIImageView(image: img)
        imgView.tintColor = .label
        imgView.contentMode = .scaleAspectFit
        imgView.isUserInteractionEnabled = true
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.accessibilityIdentifier = "PlaybackResolutionView.cancelImg"
        return imgView
    }()
    
    private let cancelStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 16.0
        stack.alignment = .center
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.accessibilityIdentifier = "PlaybackResolutionView.rootStack"
        return stack
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray2
        view.translatesAutoresizingMaskIntoConstraints = false
        view.accessibilityIdentifier = "PlaybackResolutionView.separatorView"
        return view
    }()
    
    private var cancelStackTopConstraint: NSLayoutConstraint?
    
    // MARK: Properties
    
    private let areaInsets: UIEdgeInsets
    
    // MARK: Lifecycles
    
    internal init(areaInsets: UIEdgeInsets) {
        self.areaInsets = areaInsets
        super.init(frame: .zero)
        backgroundColor = .white
        setupLayout()
    }
    
    required internal init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Layouts
    
    private func setupLayout() {
        cancelStack.addArrangedSubview(cancelImg)
        cancelStack.addArrangedSubview(cancelLabel)
        addSubview(cancelStack)
        addSubview(separatorView)
        
        cancelStackTopConstraint = cancelStack.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 8.0)
        cancelStackTopConstraint?.priority = .defaultHigh
        cancelStackTopConstraint?.identifier = "CancelView.cancelStackTopConstraint"
        cancelStackTopConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            cancelStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: areaInsets.top + 16.0),
            cancelStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 8.0)
        ])
        
        NSLayoutConstraint.activate([
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: areaInsets.top),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -areaInsets.bottom),
            separatorView.topAnchor.constraint(equalTo: topAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1.0)
        ])
    }
}
