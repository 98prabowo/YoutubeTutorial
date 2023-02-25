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
    
    internal typealias VideoDuration = (current: Float64, max: Float64)
    
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
        case didTapNormalizeButton
        case didTapMinimizeButton
        case didTapMaximizeButton
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
        btn.setImage(UIImage(systemName: "goforward.10"), for: .normal)
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
        btn.setImage(UIImage(systemName: "gobackward.10"), for: .normal)
        btn.tintColor = .white
        btn.contentVerticalAlignment = .fill
        btn.contentHorizontalAlignment = .fill
        btn.imageEdgeInsets = UIEdgeInsets(inset: 0.0)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.accessibilityIdentifier = "VideoControllerView.backwardButton"
        return btn
    }()
    
    private let playbackStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalCentering
        stack.spacing = 48.0
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.accessibilityIdentifier = "VideoControllerView.playbackStack"
        return stack
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.text = "00.00"
        label.textColor = .systemGray
        label.textAlignment = .left
        label.font = .boldSystemFont(ofSize: 14)
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityIdentifier = "VideoControllerView.durationLabel"
        return label
    }()
    
    private let sliderScrubber: UISlider = {
        let slider = UISlider()
        slider.tintColor = .systemRed
        slider.thumbTintColor = .systemRed
        slider.maximumTrackTintColor = .systemGray
        slider.setThumbImage(UIImage(named: "normal_thumb"), for: .normal)
        slider.setThumbImage(UIImage(named: "highlighted_thumb"), for: .highlighted)
        slider.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        slider.setContentHuggingPriority(.defaultLow, for: .horizontal)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.accessibilityIdentifier = "VideoControllerView.sliderScrubber"
        return slider
    }()
    
    private let maxDurationLabel: UILabel = {
        let label = UILabel()
        label.text = "05.00"
        label.textColor = .white
        label.textAlignment = .right
        label.font = .boldSystemFont(ofSize: 14)
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityIdentifier = "VideoControllerView.maxDurationLabel"
        return label
    }()
    
    private let maximizeButton: UIButton = {
        let btn = UIButton(type: .system)
        let img = UIImage(named: "maximize")
        btn.setImage(img, for: .normal)
        btn.tintColor = .white
        btn.contentVerticalAlignment = .fill
        btn.contentHorizontalAlignment = .fill
        btn.imageEdgeInsets = UIEdgeInsets(inset: 2.0)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.accessibilityIdentifier = "VideoControllerView.maximizeButton"
        return btn
    }()
    
    private let scrubberStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 8.0
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.accessibilityIdentifier = "VideoControllerView.scrubberStack"
        return stack
    }()
    
    // MARK: Properties
    
    internal let screenState = CurrentValueSubject<VideoPlayerView.ScreenState, Never>(.noScreen)
    
    internal let state = CurrentValueSubject<State, Never>(.loading)
    
    internal let action = CurrentValueSubject<Action, Never>(.emptyAction)
    
    internal let duration = CurrentValueSubject<VideoDuration, Never>((0.0, 0.0))
    
    internal let sliderValue = CurrentValueSubject<VideoDuration, Never>((0.0, 0.0))
    
    private let isMaximize = CurrentValueSubject<Bool, Never>(false)
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Lifecycles
    
    override internal init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .videoControllerBackground
        setupViews()
        bindData()
        bindAction()
    }
    
    required internal init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Layouts
    
    private func setupViews() {
        playbackStack.addArrangedSubview(backwardButton)
        playbackStack.addArrangedSubview(playbackButton)
        playbackStack.addArrangedSubview(forwardButton)
        scrubberStack.addArrangedSubview(durationLabel)
        scrubberStack.addArrangedSubview(sliderScrubber)
        scrubberStack.addArrangedSubview(maxDurationLabel)
        scrubberStack.addArrangedSubview(maximizeButton)
    }
    
    private func layoutLoadingView() {
        minimizeButton.removeFromSuperview()
        playbackStack.removeFromSuperview()
        scrubberStack.removeFromSuperview()
        
        addSubview(loadingView)
        
        NSLayoutConstraint.activate([
            loadingView.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    private func layoutPlaybackButton() {
        loadingView.stopAnimating()
        loadingView.removeFromSuperview()
        minimizeButton.removeFromSuperview()
        playbackStack.removeFromSuperview()
        scrubberStack.removeFromSuperview()
        
        addSubview(minimizeButton)
        addSubview(playbackStack)
        addSubview(scrubberStack)
        
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
        
        NSLayoutConstraint.activate([
            maximizeButton.widthAnchor.constraint(equalToConstant: 18.0),
            maximizeButton.heightAnchor.constraint(equalToConstant: 18.0)
        ])
        
        NSLayoutConstraint.activate([
            scrubberStack.leftAnchor.constraint(equalTo: leftAnchor, constant: 10.0),
            scrubberStack.rightAnchor.constraint(equalTo: rightAnchor, constant: -10.0),
            scrubberStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10.0)
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
        Publishers.CombineLatest3(
            state.eraseToAnyPublisher(),
            action.eraseToAnyPublisher(),
            sliderValue.eraseToAnyPublisher()
        )
        .receive(on: DispatchQueue.main)
        .debounce(for: .seconds(2.0), scheduler: DispatchQueue.main)
        .sink { [weak self] state, _, _ in
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
        
        duration
            .receive(on: DispatchQueue.main)
            .removeDuplicates { $0.current == $1.current }
            .sink { [weak self] current, max in
                guard let self else { return }
                self.maxDurationLabel.text = max.formattedDuration
                guard !self.sliderScrubber.isTracking else { return }
                self.durationLabel.text = current.formattedDuration
                self.sliderScrubber.value = Float(current / max)
            }
            .store(in: &cancellables)
    }
    
    private func bindAction() {
        minimizeButton.action()
            .sink { [screenState, action] in
                guard screenState.value == .normal else { return }
                action.send(.didTapMinimizeButton)
            }
            .store(in: &cancellables)
        
        maximizeButton.action()
            .sink { [action, isMaximize] in
                if isMaximize.value {
                    action.send(.didTapNormalizeButton)
                } else {
                    action.send(.didTapMaximizeButton)
                }
                let _isMaximize: Bool = !isMaximize.value
                isMaximize.send(_isMaximize)
            }
            .store(in: &cancellables)
        
        isMaximize
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [maximizeButton] isMaximize in
                if isMaximize {
                    maximizeButton.setImage(UIImage(named: "normalize"), for: .normal)
                } else {
                    maximizeButton.setImage(UIImage(named: "maximize"), for: .normal)
                }
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
        
        sliderScrubber.action(.valueChanged)
            .sink { [weak self] in
                guard let self else { return }
                let videoDuration: VideoDuration = (
                    Float64(self.sliderScrubber.value) * self.duration.value.max,
                    self.duration.value.max
                )
                self.durationLabel.text = videoDuration.current.formattedDuration
                self.sliderValue.send(videoDuration)
            }
            .store(in: &cancellables)
    }
}
