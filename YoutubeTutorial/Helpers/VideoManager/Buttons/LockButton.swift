//
//  LockButton.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 06/03/23.
//

import Combine
import UIKit

internal final class LockButton: UIView {
    // MARK: Value Types
    
    internal enum LockState: Equatable {
        case normal
        case locked
        case unlockForm
    }
    
    // MARK: UI Components
    
    private let image: UIImageView = {
        let img = UIImageView()
        img.tintColor = .white
        img.translatesAutoresizingMaskIntoConstraints = false
        img.accessibilityIdentifier = "LockImageView.image"
        return img
    }()
    
    private let title: UILabel = {
        let text = UILabel()
        text.textColor = .white
        text.font = .preferredFont(forTextStyle: .callout)
        text.translatesAutoresizingMaskIntoConstraints = false
        text.accessibilityIdentifier = "LockImageView.title"
        return text
    }()
    
    private let btnStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 4.0
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.accessibilityIdentifier = "VideoControllerView.btnStack"
        return stack
    }()
    
    private let titleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.accessibilityIdentifier = "VideoControllerView.titleView"
        return view
    }()
    
    private let lockedTitle: UILabel = {
        let text = UILabel()
        text.text = "Screen Locked"
        text.textColor = .white
        text.font = .preferredFont(forTextStyle: .headline)
        text.translatesAutoresizingMaskIntoConstraints = false
        text.accessibilityIdentifier = "LockImageView.lockedTitle"
        return text
    }()
    
    private let lockedInstruction: UILabel = {
        let text = UILabel()
        text.text = "Tap to Unlock"
        text.textColor = .white
        text.font = .preferredFont(forTextStyle: .caption2)
        text.translatesAutoresizingMaskIntoConstraints = false
        text.accessibilityIdentifier = "LockImageView.lockedInstruction"
        return text
    }()
    
    private let lockedStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 4.0
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.accessibilityIdentifier = "VideoControllerView.lockedStack"
        return stack
    }()
    
    private var imageHeightConstraint: NSLayoutConstraint?
    
    private var imageWidthConstraint: NSLayoutConstraint?
    
    // MARK: Properties
    
    internal let lockState = CurrentValueSubject<LockState, Never>(.normal)
    
    private var cancellables = Set<AnyCancellable>()
    
    private let titleText: String
    
    private let unlockForm: String = "Unlock Screen?"
    
    // MARK: Lifecycles
    
    internal init(_ template: VideoButton) {
        titleText = template.title
        title.text = template.title
        image.image = template.image
        super.init(frame: .zero)
        setupInitialLayout()
        bindData()
        bindActions()
    }
    
    required internal init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Layouts
    
    private func setupInitialLayout() {
        lockedStack.removeArrangedSubview(image)
        lockedStack.removeArrangedSubview(lockedTitle)
        lockedStack.removeArrangedSubview(lockedInstruction)
        lockedStack.removeFromSuperview()
        
        btnStack.addArrangedSubview(image)
        btnStack.addArrangedSubview(title)
        
        imageWidthConstraint = image.widthAnchor.constraint(equalToConstant: VideoButton.btnSize.width)
        imageWidthConstraint?.isActive = true
        imageWidthConstraint?.identifier = "VideoControllerView.imageWidthConstraint"
        
        imageHeightConstraint = image.heightAnchor.constraint(equalToConstant: VideoButton.btnSize.height)
        imageHeightConstraint?.isActive = true
        imageHeightConstraint?.identifier = "VideoControllerView.imageHeightConstraint"
        
        titleView.pinSubview(btnStack, .padding(10.0))
        pinSubview(titleView)
    }
    
    private func setupNormalLayout() {
        lockedStack.removeArrangedSubview(titleView)
        lockedStack.removeArrangedSubview(lockedTitle)
        lockedStack.removeArrangedSubview(lockedInstruction)
        lockedStack.removeFromSuperview()
        
        imageWidthConstraint?.constant = VideoButton.btnSize.width
        imageHeightConstraint?.constant = VideoButton.btnSize.height
        
        btnStack.spacing = 4.0
        
        title.text = titleText
            
        pinSubview(titleView)
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0.0,
            options: .curveEaseOut
        ) { [weak self] in
            guard let self else { return }
            self.layoutIfNeeded()
            self.title.textColor = .white
            self.image.tintColor = .white
            self.titleView.backgroundColor = .clear
            self.titleView.layer.cornerRadius = 0.0
        }
    }
    
    private func setupLockedLayout() {
        titleView.removeFromSuperview()
        
        lockedStack.addArrangedSubview(titleView)
        lockedStack.addArrangedSubview(lockedTitle)
        lockedStack.addArrangedSubview(lockedInstruction)
        
        let buttonSize: CGFloat = VideoButton.btnSize.width * 1.5
        
        imageWidthConstraint?.constant = buttonSize
        imageHeightConstraint?.constant = buttonSize
        
        btnStack.spacing = 0.0
        
        title.text = nil
            
        pinSubview(lockedStack)
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0.0,
            options: .curveEaseOut
        ) { [weak self] in
            guard let self else { return }
            self.layoutIfNeeded()
            self.title.textColor = .clear
            self.image.tintColor = .black
            self.titleView.backgroundColor = .white
            self.titleView.layer.cornerRadius = buttonSize / 2
        }
    }
    
    private func setupUnlockFormLayout() {
        btnStack.spacing = 4.0
        title.text = unlockForm
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0.0,
            options: .curveEaseOut
        ) { [title, btnStack] in
            title.textColor = .black
            btnStack.layoutIfNeeded()
        }
    }
    
    // MARK: Private Implementations
    
    private func bindData() {
        lockState
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] lockState in
                guard let self else { return }
                switch lockState {
                case .normal:
                    self.setupNormalLayout()
                case .locked:
                    self.setupLockedLayout()
                case .unlockForm:
                    self.setupUnlockFormLayout()
                }
            }
            .store(in: &cancellables)
        
        lockState
            .receive(on: DispatchQueue.main)
            .debounce(for: 2.0, scheduler: DispatchQueue.main)
            .sink { [weak self] lockState in
                guard let self else { return }
                switch lockState {
                case .normal, .locked:
                    break
                case .unlockForm:
                    self.lockState.send(.locked)
                }
            }
            .store(in: &cancellables)
    }
    
    private func bindActions() {
        btnStack.tap()
            .sink { [lockState] in
                guard case .normal = lockState.value else { return }
                lockState.send(.locked)
            }
            .store(in: &cancellables)
        
        lockedStack.tap()
            .sink { [lockState] in
                switch lockState.value {
                case .normal:
                    break
                case .locked:
                    lockState.send(.unlockForm)
                case .unlockForm:
                    lockState.send(.normal)
                }
            }
            .store(in: &cancellables)
    }
}
