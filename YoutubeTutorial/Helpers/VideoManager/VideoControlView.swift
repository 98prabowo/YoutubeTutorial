//
//  VideoControllerView.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 14/02/23.
//

import AVFoundation
import Combine
import UIKit

internal final class VideoControlView: UIView {
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
                self = .playing(isHidden: true, source: .userInteraction)
            case .paused:
                self = .paused(isHidden: true)
            case .finished:
                self = .finished(isHidden: true)
            }
        }
        
        internal mutating func showControlPanel() {
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
        
        internal var isPlayingPresentControl: Bool {
            switch self {
            case .loading, .paused, .finished:
                return false
            case let .playing(isHidden, _):
                return !isHidden
            }
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
        case noAction
        case screen(action: ScreenSize)
        case control(action: Control)
        
        internal enum ScreenSize: Equatable {
            case didTapNormalizeButton
            case didTapMinimizeButton
            case didTapMaximizeButton
            case didTapSpeedButton
            case didTapLockButton
            case didTapResolutionButton
        }
        
        internal enum Control: Equatable {
            case didTapPlayButton
            case didTapPauseButton
            case didTapReplayButton
            case didTapForwardButton
            case didTapBackwardButton
        }
    }
    
    // MARK: UI Components
    
    private let minimizeButton: UIButton = {
        let btn = UIButton(type: .custom)
        let img = UIImage(systemName: "chevron.down")
        btn.setImage(img, for: .normal)
        btn.tintColor = .white
        btn.contentVerticalAlignment = .fill
        btn.contentHorizontalAlignment = .fill
        btn.imageEdgeInsets = .padding(0.0)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.accessibilityIdentifier = "VideoControlView.minimizeButton"
        return btn
    }()
    
    private let loadingView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .large)
        aiv.color = .white
        aiv.startAnimating()
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.accessibilityIdentifier = "VideoControlView.loadingView"
        return aiv
    }()
    
    private let playbackButton: UIButton = {
        let btn = UIButton(type: .system)
        let img = UIImage(systemName: "pause.fill")
        btn.setImage(img, for: .normal)
        btn.tintColor = .white
        btn.contentVerticalAlignment = .fill
        btn.contentHorizontalAlignment = .fill
        btn.imageEdgeInsets = .padding(0.0)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.accessibilityIdentifier = "VideoControlView.playbackButton"
        return btn
    }()
    
    private let forwardButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "goforward.10"), for: .normal)
        btn.tintColor = .white
        btn.contentVerticalAlignment = .fill
        btn.contentHorizontalAlignment = .fill
        btn.imageEdgeInsets = .padding(0.0)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.accessibilityIdentifier = "VideoControlView.forwardButton"
        return btn
    }()
    
    private let backwardButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "gobackward.10"), for: .normal)
        btn.tintColor = .white
        btn.contentVerticalAlignment = .fill
        btn.contentHorizontalAlignment = .fill
        btn.imageEdgeInsets = .padding(0.0)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.accessibilityIdentifier = "VideoControlView.backwardButton"
        return btn
    }()
    
    private let playbackStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.spacing = 48.0
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.accessibilityIdentifier = "VideoControlView.playbackStack"
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
        label.accessibilityIdentifier = "VideoControlView.durationLabel"
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
        slider.accessibilityIdentifier = "VideoControlView.sliderScrubber"
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
        label.accessibilityIdentifier = "VideoControlView.maxDurationLabel"
        return label
    }()
    
    private let screenSizeButton: UIButton = {
        let btn = UIButton(type: .system)
        let img = UIImage(named: "maximize")
        btn.setImage(img, for: .normal)
        btn.tintColor = .white
        btn.contentVerticalAlignment = .fill
        btn.contentHorizontalAlignment = .fill
        btn.imageEdgeInsets = .padding(2.0)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.accessibilityIdentifier = "VideoControlView.screenSizeButton"
        return btn
    }()
    
    private let scrubberStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 8.0
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.accessibilityIdentifier = "VideoControlView.scrubberStack"
        return stack
    }()
    
    private let inputBtnStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fillEqually
        stack.spacing = 30.0
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.accessibilityIdentifier = "VideoControlView.inputBtnStack"
        return stack
    }()
    
    private let bottomBtnStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 0.0
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.accessibilityIdentifier = "VideoControlView.bottomBtnStack"
        return stack
    }()
    
    private var lockButton: LockButton?
    
    private var minimizeBtnConstraints = [NSLayoutConstraint]()
    
    private var playbackCenterXConstraint: NSLayoutConstraint?
    
    private var playbackCenterYConstraint: NSLayoutConstraint?
    
    private var playbackWidthConstraint: NSLayoutConstraint?
    
    private var playbackHeightConstraint: NSLayoutConstraint?
    
    private var scrubberLeadingConstraint: NSLayoutConstraint?
    
    private var scrubberTrailingConstraint: NSLayoutConstraint?
    
    private var scrubberBottomConstraint: NSLayoutConstraint?
    
    // MARK: Properties
    
    internal let screenState = CurrentValueSubject<VideoPlayerView.ScreenState, Never>(.noScreen)
    
    internal let state = CurrentValueSubject<State, Never>(.loading)
    
    internal let action = CurrentValueSubject<Action, Never>(.noAction)
    
    internal let duration = CurrentValueSubject<VideoDuration, Never>((0.0, 0.0))
    
    internal let sliderValue = CurrentValueSubject<VideoDuration, Never>((0.0, 0.0))
    
    private var cancellables = Set<AnyCancellable>()
    
    private var removedButtonIndex: Int?
    
    private let areaInsets: UIEdgeInsets
    
    internal let buttons: CurrentValueSubject<[VideoButtonType], Never>
    
    // MARK: Lifecycles
    
    internal init(areaInsets: UIEdgeInsets, buttons: [VideoButtonType] = []) {
        self.areaInsets = areaInsets
        self.buttons = CurrentValueSubject(buttons)
        super.init(frame: .zero)
        backgroundColor = .videoControllerBackground
        setupInitialLayout()
        bindData()
        bindAction()
    }
    
    required internal init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Layouts
    
    private func setupInitialLayout() {
        minimizeBtnConstraints = [
            minimizeButton.topAnchor.constraint(equalTo: topAnchor, constant: 18.0),
            minimizeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10.0),
            minimizeButton.widthAnchor.constraint(equalToConstant: 18.0),
            minimizeButton.heightAnchor.constraint(equalToConstant: 12.0)
        ]
    }
    
    private func layoutLoadingView() {
        loadingView.removeFromSuperview()
        minimizeButton.removeFromSuperview()
        playbackStack.removeFromSuperview()
        scrubberStack.removeFromSuperview()
        screenSizeButton.removeFromSuperview()
        bottomBtnStack.removeFromSuperview()
        
        addSubview(loadingView)
        loadingView.startAnimating()
        
        NSLayoutConstraint.activate([
            loadingView.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    private func layoutNormalScreen() {
        loadingView.stopAnimating()
        loadingView.removeFromSuperview()
        
        minimizeButton.removeFromSuperview()
        screenSizeButton.removeFromSuperview()
        bottomBtnStack.removeFromSuperview()
        
        playbackStack.removeArrangedSubview(backwardButton)
        playbackStack.removeArrangedSubview(playbackButton)
        playbackStack.removeArrangedSubview(forwardButton)
        playbackStack.removeFromSuperview()
        
        scrubberStack.removeArrangedSubview(durationLabel)
        scrubberStack.removeArrangedSubview(sliderScrubber)
        scrubberStack.removeArrangedSubview(maxDurationLabel)
        scrubberStack.removeArrangedSubview(screenSizeButton)
        scrubberStack.removeFromSuperview()
        
        playbackStack.addArrangedSubview(backwardButton)
        playbackStack.addArrangedSubview(playbackButton)
        playbackStack.addArrangedSubview(forwardButton)
        
        scrubberStack.addArrangedSubview(durationLabel)
        scrubberStack.addArrangedSubview(sliderScrubber)
        scrubberStack.addArrangedSubview(maxDurationLabel)
        scrubberStack.addArrangedSubview(screenSizeButton)
        
        addSubview(minimizeButton)
        addSubview(playbackStack)
        addSubview(scrubberStack)
        
        NSLayoutConstraint.activate(minimizeBtnConstraints)
        
        NSLayoutConstraint.activate([
            forwardButton.widthAnchor.constraint(equalToConstant: 35.0),
            forwardButton.heightAnchor.constraint(equalToConstant: 35.0)
        ])
        
        NSLayoutConstraint.activate([
            backwardButton.widthAnchor.constraint(equalTo: forwardButton.widthAnchor),
            backwardButton.heightAnchor.constraint(equalTo: forwardButton.heightAnchor)
        ])
        
        NSLayoutConstraint.activate([
            screenSizeButton.widthAnchor.constraint(equalToConstant: 18.0),
            screenSizeButton.heightAnchor.constraint(equalToConstant: 18.0)
        ])
        
        playbackStack.spacing = 48.0
        
        playbackCenterXConstraint?.isActive = false
        playbackCenterXConstraint = playbackStack.centerXAnchor.constraint(equalTo: centerXAnchor)
        playbackCenterXConstraint?.isActive = true
        playbackCenterXConstraint?.identifier = "VideoControllView.playbackCenterXConstraint"
        
        playbackCenterYConstraint?.isActive = false
        playbackCenterYConstraint = playbackStack.centerYAnchor.constraint(equalTo: centerYAnchor)
        playbackCenterYConstraint?.isActive = true
        playbackCenterYConstraint?.identifier = "VideoControllView.playbackCenterYConstraint"
        
        playbackWidthConstraint?.isActive = false
        playbackWidthConstraint = playbackButton.widthAnchor.constraint(equalToConstant: 50.0)
        playbackWidthConstraint?.isActive = true
        playbackWidthConstraint?.identifier = "VideoControllView.playbackWidthConstraint"
        
        playbackHeightConstraint?.isActive = false
        playbackHeightConstraint = playbackButton.heightAnchor.constraint(equalToConstant: 50.0)
        playbackHeightConstraint?.isActive = true
        playbackHeightConstraint?.identifier = "VideoControllView.playbackHeightConstraint"
        
        scrubberLeadingConstraint?.isActive = false
        scrubberLeadingConstraint = scrubberStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10.0)
        scrubberLeadingConstraint?.isActive = true
        scrubberLeadingConstraint?.identifier = "VideoControlView.scrubberLeadingConstraint"
        
        scrubberTrailingConstraint?.isActive = false
        scrubberTrailingConstraint = scrubberStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10.0)
        scrubberTrailingConstraint?.isActive = true
        scrubberTrailingConstraint?.identifier = "VideoControlView.scrubberTrailingConstraint"
        
        scrubberBottomConstraint?.isActive = false
        scrubberBottomConstraint = scrubberStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10.0)
        scrubberBottomConstraint?.isActive = true
        scrubberBottomConstraint?.identifier = "VideoControlView.scrubberBottomConstraint"
    }
    
    private func layoutMaximizeScreen(_ state: State) {
        loadingView.stopAnimating()
        loadingView.removeFromSuperview()
        
        screenSizeButton.removeFromSuperview()
        minimizeButton.removeFromSuperview()
        
        playbackStack.removeArrangedSubview(backwardButton)
        playbackStack.removeArrangedSubview(playbackButton)
        playbackStack.removeArrangedSubview(forwardButton)
        playbackStack.removeFromSuperview()
        
        scrubberStack.removeArrangedSubview(durationLabel)
        scrubberStack.removeArrangedSubview(sliderScrubber)
        scrubberStack.removeArrangedSubview(maxDurationLabel)
        scrubberStack.removeArrangedSubview(screenSizeButton)
        scrubberStack.removeFromSuperview()
        
        playbackStack.addArrangedSubview(backwardButton)
        playbackStack.addArrangedSubview(playbackButton)
        playbackStack.addArrangedSubview(forwardButton)
        
        scrubberStack.addArrangedSubview(durationLabel)
        scrubberStack.addArrangedSubview(sliderScrubber)
        scrubberStack.addArrangedSubview(maxDurationLabel)
        
        if let lockButton, let rmBtnIndex = removedButtonIndex {
            lockButton.removeFromSuperview()
            if case .finished = state {
                inputBtnStack.removeArrangedSubview(lockButton)
            } else {
                inputBtnStack.insertArrangedSubview(lockButton, at: rmBtnIndex)
            }
        }
        
        addSubview(playbackStack)
        addSubview(screenSizeButton)
        addSubview(scrubberStack)
        addSubview(bottomBtnStack)
        
        playbackStack.spacing = 96.0
        
        playbackWidthConstraint?.constant = 80.0
        playbackHeightConstraint?.constant = 80.0
        
        playbackCenterXConstraint?.isActive = true
        playbackCenterYConstraint?.isActive = true
        playbackWidthConstraint?.isActive = true
        playbackHeightConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            screenSizeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -areaInsets.bottom),
            screenSizeButton.bottomAnchor.constraint(equalTo: scrubberStack.topAnchor, constant: -8.0),
            screenSizeButton.widthAnchor.constraint(equalToConstant: 18.0),
            screenSizeButton.heightAnchor.constraint(equalToConstant: 18.0)
        ])
        
        scrubberLeadingConstraint?.constant = areaInsets.top
        scrubberLeadingConstraint?.isActive = true
        
        scrubberTrailingConstraint?.constant = -areaInsets.bottom
        scrubberTrailingConstraint?.isActive = true
        
        scrubberBottomConstraint?.isActive = false
        if inputBtnStack.arrangedSubviews.isEmpty {
            scrubberBottomConstraint = scrubberStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10.0)
        } else {
            scrubberBottomConstraint = scrubberStack.bottomAnchor.constraint(equalTo: bottomBtnStack.topAnchor, constant: -10.0)
        }
        scrubberBottomConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            bottomBtnStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: areaInsets.top),
            bottomBtnStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -areaInsets.bottom),
            bottomBtnStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10.0)
        ])
    }
    
    private func layoutLockScreen() {
        guard let lockButton,
              let removedIndex = inputBtnStack.arrangedSubviews.firstIndex(of: lockButton) else { return }
        
        removedButtonIndex = removedIndex
        
        minimizeButton.removeFromSuperview()
        playbackStack.removeFromSuperview()
        screenSizeButton.removeFromSuperview()
        scrubberStack.removeFromSuperview()
        
        bottomBtnStack.removeArrangedSubview(lockButton)
        bottomBtnStack.removeFromSuperview()
        
        addSubview(lockButton)
        
        NSLayoutConstraint.activate([
            lockButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            lockButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    // MARK: Implementations
    
    private func createLockButton(_ template: VideoButtonType) -> LockButton {
        let button = LockButton(template)
        inputBtnStack.addArrangedSubview(button)
        button.lockState
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] lockState in
                guard let self else { return }
                switch lockState {
                case .normal:
                    self.action.send(.screen(action: .didTapMaximizeButton))
                case .locked:
                    self.action.send(.screen(action: .didTapLockButton))
                case .unlockForm:
                    break
                }
            }
            .store(in: &cancellables)
        return button
    }
    
    @discardableResult
    private func createVideoButton(_ template: VideoButtonType, action: @escaping () -> Void) -> VideoButton {
        let button = VideoButton(template)
        inputBtnStack.addArrangedSubview(button)
        button.tap()
            .sink { [action] in action() }
            .store(in: &cancellables)
        return button
    }
    
    private func setupBottomButton(_ buttons: [VideoButtonType]) {
        inputBtnStack.removeAllArrangedSubviews()
        
        buttons.forEach { [weak self] btn in
            guard let self else { return }
                
            switch btn {
            case .lock:
                self.lockButton = createLockButton(btn)
                
            case .rate:
                createVideoButton(btn) { [weak self] in
                    guard let self else { return }
                    self.action.send(.screen(action: .didTapSpeedButton))
                }
                
            case .resolution:
                createVideoButton(btn) { [weak self] in
                    guard let self else { return }
                    self.action.send(.screen(action: .didTapResolutionButton))
                }
                
            case let .custom(template):
                createVideoButton(btn, action: template.action)
            }
        }
        
        bottomBtnStack.addArrangedSubview(inputBtnStack)
    }
    
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
    
    private func hideButton(isAnimating: Bool) {
        if isAnimating {
            animateHideButton()
        } else {
            directHideButton()
        }
    }
    
    private func setupForwardAndBackward(isEnabled: Bool) {
        forwardButton.isEnabled = isEnabled
        forwardButton.isHidden = !isEnabled
        forwardButton.alpha = isEnabled ? 1.0 : 0.0
        backwardButton.isEnabled = isEnabled
        backwardButton.isHidden = !isEnabled
        backwardButton.alpha = isEnabled ? 1.0 : 0.0
    }
    
    private func updatePlaybackBtn(with image: UIImage?) {
        UIView.animate(
            withDuration: 0.3,
            delay: 0.0,
            options: .curveEaseOut
        ) { [playbackButton] in
            playbackButton.setImage(image, for: .normal)
        }
    }
    
    private func bindData() {
        // Handle user inactivity
        Publishers.CombineLatest3(
            state.eraseToAnyPublisher(),
            action.eraseToAnyPublisher(),
            sliderValue.eraseToAnyPublisher()
        )
        .receive(on: DispatchQueue.main)
        .debounce(for: .seconds(3.0), scheduler: DispatchQueue.main)
        .sink { [weak self] state, action, _ in
            guard let self,
                  state.isPlayingPresentControl else { return }
            self.state.send(.playing(isHidden: true, source: .inactive))
        }
        .store(in: &cancellables)
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [weak self] action in
                guard let self else { return }
                switch action {
                case .noAction,
                        .screen,
                        .control(action: .didTapPauseButton),
                        .control(action: .didTapForwardButton),
                        .control(action: .didTapBackwardButton),
                        .control(action: .didTapPlayButton):
                    break
                case .control(action: .didTapReplayButton):
                    self.setupForwardAndBackward(isEnabled: true)
                }
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
                    self.layoutLoadingView()
                    
                case let .playing(isHidden, _):
                    self.updatePlaybackBtn(with: current.playbackIcon)

                    switch self.screenState.value {
                    case .normal:
                        self.layoutNormalScreen()
                    case let .maximize(control):
                        guard control.notLocked else { break }
                        self.layoutMaximizeScreen(current)
                    case .noScreen, .minimize:
                        break
                    }

                    if isHidden {
                        let isAnimating: Bool = previous.isPlayingPresentControl && current == .playing(isHidden: true, source: .inactive)
                        self.hideButton(isAnimating: isAnimating)
                    } else {
                        self.directShowButton()
                    }
                    
                case let .paused(isHidden):
                    self.updatePlaybackBtn(with: current.playbackIcon)

                    switch self.screenState.value {
                    case .normal:
                        self.layoutNormalScreen()
                    case let .maximize(control):
                        guard control.notLocked else { break }
                        self.layoutMaximizeScreen(current)
                    case .noScreen, .minimize:
                        break
                    }

                    if isHidden {
                        self.directHideButton()
                    } else {
                        self.directShowButton()
                    }
                    
                case let .finished(isHidden):
                    self.updatePlaybackBtn(with: current.playbackIcon)
                    self.setupForwardAndBackward(isEnabled: false)
                    
                    switch self.screenState.value {
                    case .normal:
                        self.layoutNormalScreen()
                    case .maximize:
                        self.layoutMaximizeScreen(current)
                        guard let lockButton = self.lockButton else { break }
                        lockButton.lockState.send(.normal)
                    case .noScreen, .minimize:
                        break
                    }
                    
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
        
        screenState
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] screen in
                guard let self else { return }
                switch screen {
                case let .normal(isLoading):
                    guard !isLoading else { return }
                    self.screenSizeButton.setImage(screen.screenButtonIcon, for: .normal)
                    self.layoutNormalScreen()
                case let .maximize(control):
                    self.screenSizeButton.setImage(screen.screenButtonIcon, for: .normal)
                    switch control {
                    case .active:
                        self.layoutMaximizeScreen(self.state.value)
                    case .loading:
                        self.state.send(.loading)
                    case .lock:
                        self.layoutLockScreen()
                    case .resolution, .speed:
                        break
                    }
                case .noScreen, .minimize:
                    break
                }
            }
            .store(in: &cancellables)
        
        buttons
            .receive(on: DispatchQueue.main)
            .sink { [weak self] buttons in
                guard let self else { return }
                self.setupBottomButton(buttons)
            }
            .store(in: &cancellables)
    }
    
    private func bindAction() {
        minimizeButton.action()
            .sink { [screenState, action] in
                guard case .normal = screenState.value else { return }
                action.send(.screen(action: .didTapMinimizeButton))
            }
            .store(in: &cancellables)
        
        screenSizeButton.action()
            .sink { [action, screenState] in
                switch screenState.value {
                case .normal:
                    action.send(.screen(action: .didTapMaximizeButton))
                    NotificationCenter.default.post(
                        name: .videoPlayerSizeDidChange,
                        object: nil,
                        userInfo: ["isMaximize": true]
                    )
                    
                case .maximize:
                    action.send(.screen(action: .didTapNormalizeButton))
                    NotificationCenter.default.post(
                        name: .videoPlayerSizeDidChange,
                        object: nil,
                        userInfo: ["isMaximize": false]
                    )
                    
                case .noScreen, .minimize:
                    break
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
                    self.action.send(.control(action: .didTapPauseButton))
                case .paused:
                    self.state.send(.playing(isHidden: false, source: .userInteraction))
                    self.action.send(.control(action: .didTapPlayButton))
                case .finished:
                    self.state.send(.playing(isHidden: true, source: .userInteraction))
                    self.action.send(.control(action: .didTapReplayButton))
                }
            }
            .store(in: &cancellables)
        
        forwardButton.action()
            .sink { [weak self] in
                guard let self else { return }
                self.action.send(.control(action: .didTapForwardButton))
            }
            .store(in: &cancellables)
        
        backwardButton.action()
            .sink { [weak self] in
                guard let self else { return }
                self.action.send(.control(action: .didTapBackwardButton))
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
    
    // MARK: Interfaces
    
    internal func insertButton(_ button: VideoButtonType, at index: Int) {
        var _buttons = buttons.value
        _buttons.insert(button, at: index)
        buttons.send(_buttons)
    }
}
