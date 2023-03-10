//
//  VideoView.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 14/02/23.
//

import Combine
import UIKit

internal final class VideoView: UIView {
    // MARK: UI Components
    
    private var videoPlayer: VideoPlayerView?
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .label
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityIdentifier = "VideoPlayerView.titleLabel"
        return label
    }()
    
    private var channelLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .label
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityIdentifier = "VideoPlayerView.channelLabel"
        return label
    }()
    
    private lazy var titleStack: UIStackView = {
        let titleStack = UIStackView()
        titleStack.axis = .vertical
        titleStack.alignment = .leading
        titleStack.distribution = .fill
        titleStack.spacing = 8.0
        titleStack.translatesAutoresizingMaskIntoConstraints = false
        titleStack.accessibilityIdentifier = "VideoPlayerView.titleStack"
        return titleStack
    }()
    
    private let minimizeStack: UIStackView = {
        let rootStack = UIStackView()
        rootStack.axis = .horizontal
        rootStack.alignment = .center
        rootStack.distribution = .fillProportionally
        rootStack.spacing = 8.0
        rootStack.translatesAutoresizingMaskIntoConstraints = false
        rootStack.accessibilityIdentifier = "VideoPlayerView.rootStack"
        return rootStack
    }()
    
    private var playbackButton: UIButton = {
        let btn = UIButton(type: .system)
        let img = UIImage(systemName: "pause.fill")
        btn.setImage(img, for: .normal)
        btn.tintColor = .label
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.accessibilityIdentifier = "VideoView.playbackButton"
        return btn
    }()
    
    private var closeButton: UIButton = {
        let btn = UIButton(type: .system)
        let img = UIImage(systemName: "xmark")
        btn.setImage(img, for: .normal)
        btn.tintColor = .label
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.accessibilityIdentifier = "VideoView.closeButton"
        return btn
    }()
    
    private var heightConstraint: NSLayoutConstraint?
    
    private var bottomContraint: NSLayoutConstraint?
    
    private var leadingConstraintVideoPlayer: NSLayoutConstraint?
    
    private var trailingConstraintVideoPlayer: NSLayoutConstraint?
    
    private var topConstraintVideoPlayer: NSLayoutConstraint?
    
    private var bottomConstraintVideoPlayer: NSLayoutConstraint?
    
    private var heightConstraintVideoPlayer: NSLayoutConstraint?
    
    private var widthConstraintVideoPlayer: NSLayoutConstraint?
    
    // MARK: Properties
    
    internal let closePlayer = PassthroughSubject<Void, Never>()
    
    internal var cancellables = Set<AnyCancellable>()
    
    private var windowUI: UIWindow? {
        guard let scene = UIApplication.shared.connectedScenes.first,
              let windowSceneDelegate = scene.delegate as? UIWindowSceneDelegate,
              let window = windowSceneDelegate.window else { return nil }
        return window
    }
    
    private let video: Video
    
    private let areaInsets: UIEdgeInsets
    
    // MARK: Lifecycles
    
    internal init(_ video: Video, areaInsets: UIEdgeInsets) {
        self.video = video
        self.areaInsets = areaInsets
        super.init(frame: .zero)
        backgroundColor = .white
        translatesAutoresizingMaskIntoConstraints = false
        setupViews()
        bindData()
        bindAction()
    }
    
    required internal init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
#if DEBUG
    deinit {
        print(">>> \(String(describing: Self.self)) deinitialize safely 👍🏽")
    }
#endif
    
    // MARK: Layouts
    
    private func setupLayout() {
        guard let window = windowUI, let videoPlayer else { return }
        window.addSubview(self)
        addSubview(videoPlayer)
        
        let initialHeight: CGFloat = 0.0
        
        // Handle video view contraint
        bottomContraint = bottomAnchor.constraint(equalTo: window.bottomAnchor)
        bottomContraint?.isActive = true
        bottomContraint?.identifier = "VideoView.bottomContraint"
        
        heightConstraint = heightAnchor.constraint(equalToConstant: initialHeight)
        heightConstraint?.isActive = true
        heightConstraint?.identifier = "VideoView.heightConstraint"
        
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: window.leadingAnchor),
            trailingAnchor.constraint(equalTo: window.trailingAnchor)
        ])
        
        // Handle video player constraint
        topConstraintVideoPlayer = videoPlayer.topAnchor.constraint(equalTo: topAnchor)
        topConstraintVideoPlayer?.isActive = true
        topConstraintVideoPlayer?.identifier = "VideoView.topConstraintVideoPlayer"
        
        leadingConstraintVideoPlayer = videoPlayer.leadingAnchor.constraint(equalTo: leadingAnchor)
        leadingConstraintVideoPlayer?.isActive = true
        leadingConstraintVideoPlayer?.identifier = "VideoView.leadingConstraintVideoPlayer"
        
        trailingConstraintVideoPlayer = videoPlayer.trailingAnchor.constraint(equalTo: trailingAnchor)
        trailingConstraintVideoPlayer?.isActive = true
        trailingConstraintVideoPlayer?.identifier = "VideoView.trailingConstraintVideoPlayer"
        
        heightConstraintVideoPlayer = videoPlayer.heightAnchor.constraint(equalToConstant: initialHeight)
        heightConstraintVideoPlayer?.isActive = true
        heightConstraintVideoPlayer?.identifier = "VideoView.heightConstraintVideoPlayer"
        
        videoPlayer.resizePlayerLayer(with: CGSizeMake(window.bounds.width, initialHeight))
        
        layoutIfNeeded()
        videoPlayer.layoutIfNeeded()
    }
    
    private func setupLayoutNoScreen() {
        videoPlayer?.removeFromSuperview()
        minimizeStack.removeFromSuperview()
        removeFromSuperview()
        videoPlayer = nil
    }
    
    private func setupLayoutNormal(_ previousState: VideoPlayerView.ScreenState? = nil) {
        guard let window = windowUI, let videoPlayer else { return }
        
        backgroundColor = .white
        
        let videoHeight: CGFloat = window.frame.width * (9 / 16) // Use video pixel aspect ratio w: 16 h: 9
        
        if case .maximize = previousState {
            UIView.animate(
                withDuration: 0.5,
                delay: 0.0,
                options: .curveEaseOut
            ) { [areaInsets] in
                videoPlayer.transform = .identity
                videoPlayer.frame = CGRectMake(0.0, areaInsets.top, window.frame.height, videoHeight)
            }
            videoPlayer.translatesAutoresizingMaskIntoConstraints = false
        }
        
        videoPlayer.removeFromSuperview()
        
        if previousState == .minimize {
            minimizeStack.removeFromSuperview()
            // Handle video player constraint
            widthConstraintVideoPlayer?.isActive = false
        }
        
        addSubview(videoPlayer)
        
        leadingConstraintVideoPlayer = videoPlayer.leadingAnchor.constraint(equalTo: leadingAnchor)
        leadingConstraintVideoPlayer?.isActive = true
        leadingConstraintVideoPlayer?.identifier = "VideoView.leadingConstraintVideoPlayer"
        
        trailingConstraintVideoPlayer = videoPlayer.trailingAnchor.constraint(equalTo: trailingAnchor)
        trailingConstraintVideoPlayer?.isActive = true
        trailingConstraintVideoPlayer?.identifier = "VideoView.trailingConstraintVideoPlayer"
        
        topConstraintVideoPlayer = videoPlayer.topAnchor.constraint(equalTo: topAnchor, constant: areaInsets.top)
        topConstraintVideoPlayer?.isActive = true
        topConstraintVideoPlayer?.identifier = "VideoView.topConstraintVideoPlayer"
        
        bottomConstraintVideoPlayer?.isActive = false
        
        heightConstraintVideoPlayer?.isActive = false
        heightConstraintVideoPlayer = videoPlayer.heightAnchor.constraint(equalToConstant: videoHeight)
        heightConstraintVideoPlayer?.isActive = true
        heightConstraintVideoPlayer?.identifier = "VideoView.heightConstraintVideoPlayer"
        
        videoPlayer.layoutIfNeeded()
        
        videoPlayer.resizePlayerLayer(with: CGSizeMake(window.bounds.width, videoHeight))
        
        // Handle video view contraint
        heightConstraint?.constant = window.frame.height
        
        bottomContraint?.isActive = false
        bottomContraint = bottomAnchor.constraint(equalTo: window.bottomAnchor)
        bottomContraint?.isActive = true
        
        UIView.animate(withDuration: 0.1) { [weak self] in
            guard let self else { return }
            self.videoPlayer?.layoutIfNeeded()
            self.layoutIfNeeded()
        } completion: { [videoPlayer] _ in
            guard let previousState, previousState == .noScreen else { return }
            videoPlayer.play()
        }
    }
    
    private func setupLayoutMinimize() {
        guard let window = windowUI, let videoPlayer else { return }
        
        backgroundColor = .white
        
        removeFromSuperview()
        videoPlayer.removeFromSuperview()
        
        window.addSubview(self)
        
        // Handle label
        titleLabel.numberOfLines = 1
        titleLabel.font = .preferredFont(forTextStyle: .caption1)
        
        channelLabel.font = .preferredFont(forTextStyle: .caption2)
        channelLabel.textColor = .secondaryLabel
        
        // Handle button contraint
        let buttonSize: CGFloat = 40.0
        
        NSLayoutConstraint.activate([
            playbackButton.heightAnchor.constraint(equalToConstant: buttonSize),
            playbackButton.widthAnchor.constraint(equalToConstant: buttonSize)
        ])
        
        NSLayoutConstraint.activate([
            closeButton.heightAnchor.constraint(equalToConstant: buttonSize),
            closeButton.widthAnchor.constraint(equalToConstant: buttonSize)
        ])
        
        // Handle video view contraint
        let videoHeight: CGFloat = 60.0
        heightConstraint?.constant = videoHeight
        
        bottomContraint?.isActive = false
        bottomContraint = bottomAnchor.constraint(equalTo: window.safeAreaLayoutGuide.bottomAnchor)
        bottomContraint?.isActive = true
        
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: window.leadingAnchor),
            trailingAnchor.constraint(equalTo: window.trailingAnchor)
        ])
        
        // Handle video player constraint
        leadingConstraintVideoPlayer?.isActive = false
        trailingConstraintVideoPlayer?.isActive = false
        topConstraintVideoPlayer?.isActive = false
        bottomConstraintVideoPlayer?.isActive = false
        
        heightConstraintVideoPlayer?.constant = videoHeight
        
        let videoWidth: CGFloat = videoHeight * (16 / 9) // Use video pixel aspect ratio w: 16 h: 9
        widthConstraintVideoPlayer?.isActive = false
        widthConstraintVideoPlayer = videoPlayer.widthAnchor.constraint(equalToConstant: videoWidth)
        widthConstraintVideoPlayer?.isActive = true
        widthConstraintVideoPlayer?.identifier = "VideoView.widthConstraintVideoPlayer"
        
        videoPlayer.resizePlayerLayer(with: CGSizeMake(videoWidth, videoHeight))
        
        // Handle minimize stack
        minimizeStack.addArrangedSubview(videoPlayer)
        minimizeStack.addArrangedSubview(titleStack)
        minimizeStack.addArrangedSubview(playbackButton)
        minimizeStack.addArrangedSubview(closeButton)
        
        pinSubview(self.minimizeStack)
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0.0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut
        ) { [weak self] in
            guard let self else { return }
            self.videoPlayer?.layoutIfNeeded()
            self.layoutIfNeeded()
        }
    }
    
    private func setupLayoutMaximize() {
        guard let window = windowUI, let videoPlayer else { return }
        
        backgroundColor = .black
        
        let videoWidth: CGFloat = window.frame.height
        let videoHeight: CGFloat = window.frame.width
        
        videoPlayer.removeFromSuperview()
        videoPlayer.translatesAutoresizingMaskIntoConstraints = true
        addSubview(videoPlayer)
        
        heightConstraintVideoPlayer?.isActive = false
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0.0,
            options: .curveEaseOut
        ) {
            videoPlayer.resizePlayerLayer(with: CGSizeMake(videoWidth, videoHeight))
            videoPlayer.transform = CGAffineTransform(rotationAngle: .pi / 2)
            videoPlayer.bounds = CGRectMake(0, 0, videoWidth, videoHeight)
            videoPlayer.center = window.center
        }
    }
    
    private func setupLayoutMaximizeDeviceRotation(orientation: UIDeviceOrientation) {
        guard let window = windowUI, let videoPlayer else { return }
        switch orientation {
        case .landscapeLeft:
            UIView.animate(
                withDuration: 0.5,
                delay: 0.0,
                options: .curveEaseOut
            ) {
                videoPlayer.transform = CGAffineTransform(rotationAngle: .pi / 2)
                videoPlayer.center = window.center
            }
        case .landscapeRight:
            UIView.animate(
                withDuration: 0.5,
                delay: 0.0,
                options: .curveEaseOut
            ) {
                videoPlayer.transform = CGAffineTransform(rotationAngle: -(.pi / 2))
                videoPlayer.center = window.center
            }
        case .portrait, .portraitUpsideDown, .faceUp, .faceDown, .unknown:
            break
        @unknown default:
            break
        }
    }
    
    // MARK: Implementations
    
    private func setupViews() {
        titleLabel.text = video.title
        channelLabel.text = video.channel.name
        titleStack.addArrangedSubview(titleLabel)
        titleStack.addArrangedSubview(channelLabel)
        
        videoPlayer = VideoPlayerView(for: EndPoint.video.url, areaInsets: areaInsets)
        videoPlayer?.translatesAutoresizingMaskIntoConstraints = false
        videoPlayer?.accessibilityIdentifier = "VideoView.videoPlayer"
    }
    
    private func bindData() {
        guard let videoPlayer else { return }
        
        videoPlayer.screenState
            .dropFirst()
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .withPrevious(.noScreen)
            .sink { [weak self] previousState, currentState in
                guard let self else { return }
                switch currentState {
                case .noScreen:
                    videoPlayer.stopPlaying()
                    self.videoPlayer = nil
                    self.setupLayoutNoScreen()
                case .normal:
                    self.setupLayoutNormal(previousState)
                case .minimize:
                    self.setupLayoutMinimize()
                case .maximize:
                    self.setupLayoutMaximize()
                }
            }
            .store(in: &cancellables)
        
        videoPlayer.controlView.state
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [playbackButton] state in
                playbackButton.setImage(state.playbackIcon, for: .normal)
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .receive(on: DispatchQueue.main)
            .mapToVoid()
            .sink { [weak self] in
                guard let self,
                      case .maximize = videoPlayer.screenState.value else { return }
                let orientation: UIDeviceOrientation = UIDevice.current.orientation
                self.setupLayoutMaximizeDeviceRotation(orientation: orientation)
            }
            .store(in: &cancellables)
    }
    
    private func bindAction() {
        guard let videoPlayer else { return }
        
        tap()
            .sink { [videoPlayer] in
                switch videoPlayer.screenState.value {
                case .noScreen, .normal, .maximize:
                    break
                case .minimize:
                    videoPlayer.screenState.send(.normal(isLoading: false))
                }
            }
            .store(in: &cancellables)
        
        playbackButton.action()
            .sink { [videoPlayer] in
                switch videoPlayer.controlView.state.value {
                case .loading:
                    return
                case .playing:
                    videoPlayer.controlView.state.send(.paused(isHidden: false))
                    videoPlayer.controlView.action.send(.control(action: .didTapPauseButton))
                case .paused:
                    videoPlayer.controlView.state.send(.playing(isHidden: false, source: .userInteraction))
                    videoPlayer.controlView.action.send(.control(action: .didTapPlayButton))
                case .finished:
                    videoPlayer.controlView.state.send(.playing(isHidden: true, source: .userInteraction))
                    videoPlayer.controlView.action.send(.control(action: .didTapReplayButton))
                }
            }
            .store(in: &cancellables)
        
        closeButton.action()
            .sink { [videoPlayer, closePlayer] in
                videoPlayer.screenState.send(.noScreen)
                closePlayer.send(())
            }
            .store(in: &cancellables)
    }
    
    // MARK: Interfaces
    
    internal func stopVideoPlayer() {
        guard let videoPlayer else { return }
        videoPlayer.screenState.send(.noScreen)
    }
    
    internal func startVideoPlayer() {
        guard let videoPlayer else { return }
        setupLayout()
        videoPlayer.screenState.send(.normal(isLoading: true))
    }
    
    internal func showFullScreen() {
        guard let videoPlayer else { return }
        videoPlayer.screenState.send(.normal(isLoading: false))
    }
}
