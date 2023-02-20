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
        
        internal var isPlayingPresentControl: Bool {
            self == .playing(isHidden: false, source: .system) ||
            self == .playing(isHidden: false, source: .inactive) ||
            self == .playing(isHidden: false, source: .userInteraction)
        }
    }
    
    internal enum Action: Equatable {
        case didTapPlayButton
        case didTapPauseButton
        case didTapReplayButton
    }
    
    // MARK: UI Components
    
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
        btn.accessibilityIdentifier = "VideoControllerView.pauseButton"
        return btn
    }()
    
    // MARK: Properties
    
    internal let state = CurrentValueSubject<State, Never>(.loading)
    
    internal let action = PassthroughSubject<Action, Never>()
    
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
        playbackButton.removeFromSuperview()
        addSubview(loadingView)
        NSLayoutConstraint.activate([
            loadingView.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    private func layoutPlaybackButton() {
        loadingView.stopAnimating()
        loadingView.removeFromSuperview()
        playbackButton.removeFromSuperview()
        addSubview(playbackButton)
        NSLayoutConstraint.activate([
            playbackButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            playbackButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            playbackButton.widthAnchor.constraint(equalToConstant: 50.0),
            playbackButton.heightAnchor.constraint(equalToConstant: 50.0)
        ])
    }
    
    private func animateHideButton() {
        UIView.animate(withDuration: 1.0) {
            self.alpha = 0.0
            self.playbackButton.alpha = 0.0
        } completion: { _ in
            self.playbackButton.isHidden = true
        }
    }
    
    private func directHideButton() {
        alpha = 0.0
        playbackButton.alpha = 0.0
        playbackButton.isHidden = true
    }
    
    private func directShowButton() {
        alpha = 1.0
        playbackButton.alpha = 1.0
        playbackButton.isHidden = false
    }
    
    // MARK: Implementations
    
    private func bindData() {
        // Handle user inactivity
        state
            .removeDuplicates()
            .debounce(for: .seconds(2.0), scheduler: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
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
                    self.playbackButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
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
                    self.playbackButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
                    self.layoutPlaybackButton()
                    if isHidden {
                        self.directHideButton()
                    } else {
                        self.directShowButton()
                    }
                    
                case let .finished(isHidden):
                    self.playbackButton.setImage(UIImage(systemName: "gobackward"), for: .normal)
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
    }
}
