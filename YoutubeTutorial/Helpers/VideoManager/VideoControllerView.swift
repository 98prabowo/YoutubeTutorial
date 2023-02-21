//
//  VideoControllerView.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 14/02/23.
//

import AVFoundation
import Combine
import UIKit

internal final class VideoControllerView: UIView {
    // MARK: Type Values
    
    internal enum State: Equatable {
        case loading
        case playing(isHidden: Bool, source: ToggleSource)
        case paused(isHidden: Bool)
        case finished(isHidden: Bool)
        
        internal enum ToggleSource: Equatable {
            case system
            case inactive
            case userInteraction
        }
        
        internal mutating func toggleHidden() {
            switch self {
            case .loading:
                break
            case let .playing(isHidden, _):
                self = .playing(isHidden: !isHidden, source: .userInteraction)
            case let .paused(isHidden):
                self = .paused(isHidden: !isHidden)
            case let .finished(isHidden):
                self = .finished(isHidden: !isHidden)
            }
        }
        
        internal mutating func hideControlPanel() {
            switch self {
            case .loading:
                break
            case .playing:
                self = .playing(isHidden: false, source: .userInteraction)
            case .paused:
                self = .paused(isHidden: false)
            case .finished:
                self = .finished(isHidden: false)
            }
        }
        
        internal mutating func showControlPanel() {
            switch self {
            case .loading:
                break
            case .playing:
                self = .playing(isHidden: true, source: .userInteraction)
            case .paused:
                self = .paused(isHidden: true)
            case .finished:
                self = .finished(isHidden: true)
            }
        }
        
        internal var isPlayingPresentControl: Bool {
            self == .playing(isHidden: false, source: .system) ||
            self == .playing(isHidden: false, source: .inactive) ||
            self == .playing(isHidden: false, source: .userInteraction)
        }
        
        internal var playbackIcon: UIImage? {
            switch self {
            case .loading:
                return nil
            case .playing:
                return UIImage(systemName: "pause.fill")
            case .paused:
                return UIImage(systemName: "play.fill")
            case .finished:
                return UIImage(systemName: "gobackward")
            }
        }
    }
    
    internal enum Action: Equatable {
        case emptyAction
        case didTapMinimizeButton
        case didTapPlayButton
        case didTapPauseButton
        case didTapReplayButton
        case didTapForwardButton
        case didTapBackwardButton
    }
    
    // MARK: UI Components
    
    private let minimizeButton: UIButton = {
        let btn = UIButton(type: .system)
        let img = UIImage(systemName: "chevron.down")
        btn.setImage(img, for: .normal)
        btn.tintColor = .white
        btn.contentVerticalAlignment = .fill
        btn.contentHorizontalAlignment = .fill
        btn.imageEdgeInsets = UIEdgeInsets(inset: 0.0)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.accessibilityIdentifier = "VideoControllerView.minimizeButton"
        return btn
    }()
    
    private let loadingView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .large)
        aiv.startAnimating()
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.accessibilityIdentifier = "VideoControllerView.loadingView"
        return aiv
    }()
    
    private let playbackButton: UIButton = {
        let btn = UIButton(type: .system)
        let img = UIImage(systemName: "pause.fill")
        btn.setImage(img, for: .normal)
        btn.tintColor = .white
        btn.contentVerticalAlignment = .fill
        btn.contentHorizontalAlignment = .fill
        btn.imageEdgeInsets = UIEdgeInsets(inset: 0.0)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.accessibilityIdentifier = "VideoControllerView.playbackButton"
        return btn
    }()
    
    private let forwardButton: UIButton = {
        let btn = UIButton(type: .system)
        let img = UIImage(systemName: "goforward.10")
        btn.setImage(img, for: .normal)
        btn.tintColor = .white
        btn.contentVerticalAlignment = .fill
        btn.contentHorizontalAlignment = .fill
        btn.imageEdgeInsets = UIEdgeInsets(inset: 0.0)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.accessibilityIdentifier = "VideoControllerView.forwardButton"
        return btn
    }()
    
    private let backwardButton: UIButton = {
        let btn = UIButton(type: .system)
        let img = UIImage(systemName: "gobackward.10")
        btn.setImage(img, for: .normal)
        btn.tintColor = .white
        btn.contentVerticalAlignment = .fill
        btn.contentHorizontalAlignment = .fill
        btn.imageEdgeInsets = UIEdgeInsets(inset: 0.0)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.accessibilityIdentifier = "VideoControllerView.backwardButton"
        return btn
    }()
    
    private lazy var playbackStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [backwardButton, playbackButton, forwardButton])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalCentering
        stack.spacing = 48.0
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.accessibilityIdentifier = "VideoControllerView.playbackStack"
        return stack
    }()
    
    // MARK: Properties
    
    internal let state = CurrentValueSubject<State, Never>(.loading)
    
    internal let action = CurrentValueSubject<Action, Never>(.emptyAction)
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Lifecycles
    
    override internal init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .videoControllerBackground
        bindData()
        bindAction()
    }
    
    required internal init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Layouts
    
    private func layoutLoadingView() {
        minimizeButton.removeFromSuperview()
        playbackStack.removeFromSuperview()
        
        addSubview(loadingView)
        
        NSLayoutConstraint.activate([
            loadingView.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    private func layoutPlaybackButton() {
        loadingView.stopAnimating()
        loadingView.removeFromSuperview()
        playbackStack.removeFromSuperview()
        
        addSubview(minimizeButton)
        addSubview(playbackStack)
        
        NSLayoutConstraint.activate([
            minimizeButton.topAnchor.constraint(equalTo: topAnchor, constant: 18.0),
            minimizeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10.0),
            minimizeButton.widthAnchor.constraint(equalToConstant: 18.0),
            minimizeButton.heightAnchor.constraint(equalToConstant: 12.0)
        ])
        
        NSLayoutConstraint.activate([
            playbackButton.widthAnchor.constraint(equalToConstant: 50.0),
            playbackButton.heightAnchor.constraint(equalToConstant: 50.0)
        ])
        
        NSLayoutConstraint.activate([
            forwardButton.widthAnchor.constraint(equalToConstant: 35.0),
            forwardButton.heightAnchor.constraint(equalToConstant: 35.0)
        ])
        
        NSLayoutConstraint.activate([
            backwardButton.widthAnchor.constraint(equalTo: forwardButton.widthAnchor),
            backwardButton.heightAnchor.constraint(equalTo: forwardButton.heightAnchor)
        ])
        
        NSLayoutConstraint.activate([
            playbackStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            playbackStack.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    // MARK: Implementations
    
    private func animateHideButton() {
        UIView.animate(withDuration: 1.0) {
            self.alpha = 0.0
            
            self.minimizeButton.alpha = 0.0
            self.playbackButton.alpha = 0.0
            self.forwardButton.alpha = 0.0
            self.backwardButton.alpha = 0.0
        } completion: { _ in
            self.minimizeButton.isHidden = true
            self.playbackButton.isHidden = true
            self.forwardButton.isHidden = true
            self.backwardButton.isHidden = true
        }
    }
    
    private func directHideButton() {
        alpha = 0.0
        
        minimizeButton.alpha = 0.0
        playbackButton.alpha = 0.0
        forwardButton.alpha = 0.0
        backwardButton.alpha = 0.0
        
        minimizeButton.isHidden = true
        playbackButton.isHidden = true
        forwardButton.isHidden = true
        backwardButton.isHidden = true
    }
    
    private func directShowButton() {
        alpha = 1.0
        
        minimizeButton.alpha = 1.0
        playbackButton.alpha = 1.0
        forwardButton.alpha = 1.0
        backwardButton.alpha = 1.0
        
        minimizeButton.isHidden = false
        playbackButton.isHidden = false
        forwardButton.isHidden = false
        backwardButton.isHidden = false
    }
    
    private func disableForwardAndBackward() {
        forwardButton.isEnabled = false
        backwardButton.isEnabled = false
    }
    
    private func bindData() {
        // Handle user inactivity
        Publishers.CombineLatest(
            state.eraseToAnyPublisher(),
            action.eraseToAnyPublisher()
        )
        .debounce(for: .seconds(2.0), scheduler: DispatchQueue.main)
        .receive(on: DispatchQueue.main)
        .sink { [weak self] state, _ in
            guard let self,
                  state.isPlayingPresentControl else { return }
            self.state.send(.playing(isHidden: true, source: .inactive))
        }
        .store(in: &cancellables)
        
        state
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .withPrevious(.loading)
            .sink { [weak self] previous, current in
                guard let self else { return }
                
                switch current {
                case .loading:
                    self.alpha = 1.0
                    self.loadingView.startAnimating()
                    self.layoutLoadingView()
                    
                case let .playing(isHidden, _):
                    self.playbackButton.setImage(current.playbackIcon, for: .normal)
                    self.layoutPlaybackButton()
                    if isHidden {
                        if previous.isPlayingPresentControl,
                           current == .playing(isHidden: true, source: .inactive) {
                            self.animateHideButton()
                        } else {
                            self.directHideButton()
                        }
                    } else {
                        self.directShowButton()
                    }
                    
                case let .paused(isHidden):
                    self.playbackButton.setImage(current.playbackIcon, for: .normal)
                    self.layoutPlaybackButton()
                    if isHidden {
                        self.directHideButton()
                    } else {
                        self.directShowButton()
                    }
                    
                case let .finished(isHidden):
                    self.playbackButton.setImage(current.playbackIcon, for: .normal)
                    self.disableForwardAndBackward()
                    self.layoutPlaybackButton()
                    if isHidden {
                        self.directHideButton()
                    } else {
                        self.directShowButton()
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func bindAction() {
        minimizeButton.action()
            .sink { [weak self] in
                guard let self else { return }
                self.action.send(.didTapMinimizeButton)
            }
            .store(in: &cancellables)
        
        playbackButton.action()
            .sink { [weak self] in
                guard let self else { return }
                switch self.state.value {
                case .loading:
                    return
                case .playing:
                    self.state.send(.paused(isHidden: false))
                    self.action.send(.didTapPauseButton)
                case .paused:
                    self.state.send(.playing(isHidden: false, source: .userInteraction))
                    self.action.send(.didTapPlayButton)
                case .finished:
                    self.state.send(.playing(isHidden: true, source: .userInteraction))
                    self.action.send(.didTapReplayButton)
                }
            }
            .store(in: &cancellables)
        
        forwardButton.action()
            .sink { [weak self] in
                guard let self else { return }
                self.action.send(.didTapForwardButton)
            }
            .store(in: &cancellables)
        
        backwardButton.action()
            .sink { [weak self] in
                guard let self else { return }
                self.action.send(.didTapBackwardButton)
            }
            .store(in: &cancellables)
    }
}
