//
//  VideoPlayerView.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 14/02/23.
//

import AVFoundation
import Combine
import UIKit

internal final class VideoPlayerView: UIView {
    // MARK: Type Values
    
    internal enum ScreenState: Equatable {
        case noScreen
        case normal
        case minimize
        case maximize(isLocked: Bool)
        
        internal var screenButtonIcon: UIImage? {
            switch self {
            case .normal:
                return UIImage(named: "maximize")
            case .maximize:
                return UIImage(named: "normalize")
            case .noScreen, .minimize:
                return nil
            }
        }
    }
    
    // MARK: UI Components
    
    internal lazy var controlView: VideoControllerView = {
        let view = VideoControllerView(areaInsets: areaInsets, buttons: [.lock])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.accessibilityIdentifier = "VideoPlayerView.controlView"
        return view
    }()
    
    // MARK: Properties
    
    private lazy var asset: AVURLAsset? = {
        guard let url = URL(string: urlString) else { return nil }
        let asset: AVURLAsset = AVURLAsset(url: url, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
        return asset
    }()
    
    private lazy var playerItem: AVPlayerItem? = {
        guard let asset else { return nil }
        let playerItem: AVPlayerItem = AVPlayerItem(asset: asset)
        return playerItem
    }()
    
    private lazy var player: AVPlayer? = {
        guard let playerItem else { return nil }
        let player = AVPlayer(playerItem: playerItem)
        return player
    }()
    
    private lazy var playerLayer: AVPlayerLayer = {
        let layer = AVPlayerLayer(player: player)
        layer.contentsGravity = .resizeAspect
        return layer
    }()
    
    internal let screenState = CurrentValueSubject<ScreenState, Never>(.noScreen)
    
    private let seekDuration: Float64 = 10 // seconds
    
    private var dataCancellables = Set<AnyCancellable>()
    
    private var actionCancellables = Set<AnyCancellable>()
    
    private let urlString: String
    
    private let areaInsets: UIEdgeInsets
    
    // MARK: Lifecycles
    
    internal init(for urlString: String, areaInsets: UIEdgeInsets) {
        self.urlString = urlString
        self.areaInsets = areaInsets
        super.init(frame: .zero)
        backgroundColor = .black
        clipsToBounds = true
        setupLayout()
        bindData()
        bindAction()
    }
    
    required internal init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Layouts
    
    private func setupLayout() {
        layer.addSublayer(playerLayer)
    }
    
    private func setupLayoutNoScreen() {
        controlView.removeFromSuperview()
    }
    
    private func setupLayoutNormal() {
        controlView.removeFromSuperview()
        pinSubview(controlView)
    }
    
    private func setupLayoutMinimize() {
        controlView.removeFromSuperview()
    }
    
    private func setupLayoutMaximize() {
        controlView.removeFromSuperview()
        pinSubview(controlView)
    }
    
    // MARK: Implementations
    
    private func bindData() {
        guard let player else { return }
        player.periodicTimePublisher()
            .sink { [controlView] time in
                if let item = player.currentItem {
                    let currentDuration: Float64 = CMTimeGetSeconds(item.currentTime())
                    let maxDuration: Float64 = CMTimeGetSeconds(item.duration)
                    controlView.duration.send((currentDuration, maxDuration))
                }
                
                guard time.value == 0 else { return }
                controlView.state.send(.playing(isHidden: true, source: .system))
            }
            .store(in: &dataCancellables)
        
        player.finishPlayPublisher()
            .sink { [controlView] in
                controlView.state.send(.finished(isHidden: false))
            }
            .store(in: &dataCancellables)
        
        controlView.sliderValue
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .sink { [controlView] current, _ in
                let seekTime: CMTime = CMTimeMake(value: Int64(current), timescale: 1)
                player.seek(to: seekTime)
                guard controlView.state.value == .finished(isHidden: false) else { return }
                controlView.state.send(.playing(isHidden: false, source: .userInteraction))
                controlView.action.send(.control(action: .didTapPlayButton))
            }
            .store(in: &dataCancellables)
    }
    
    private func bindAction() {
        tap()
            .sink { [controlView, screenState] in
                switch screenState.value {
                case .normal, .maximize:
                    var state = controlView.state.value
                    state.toggleHidden()
                    controlView.state.send(state)
                    
                case .minimize:
                    screenState.send(.normal)
                    
                case .noScreen:
                    break
                }
            }
            .store(in: &actionCancellables)
        
        controlView.action
            .receive(on: DispatchQueue.main)
            .sink { [weak self] action in
                guard let self else { return }
                switch action {
                case .noAction:
                    break
                    
                case let .screen(screenAction):
                    switch screenAction {
                    case .didTapNormalizeButton:
                        self.screenState.send(.normal)
                    case .didTapMinimizeButton:
                        self.screenState.send(.minimize)
                    case .didTapMaximizeButton:
                        self.screenState.send(.maximize(isLocked: false))
                    case .didTapLockButton:
                        self.screenState.send(.maximize(isLocked: true))
                    }
                    
                case let .control(controlAction):
                    switch controlAction {
                    case .didTapPlayButton:
                        self.play()
                    case .didTapPauseButton:
                        self.pause()
                    case .didTapReplayButton:
                        self.replay()
                    case .didTapForwardButton:
                        self.goForward()
                    case .didTapBackwardButton:
                        self.goBackward()
                    }
                }
            }
            .store(in: &actionCancellables)
        
        screenState
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self else { return }
                
                // Sync screen state with screen state in control view
                self.controlView.screenState.send(state)
                
                // Handle layouts and actions
                switch state {
                case .noScreen:
                    self.setupLayoutNoScreen()
                    self.pause()
                case .normal:
                    self.setupLayoutNormal()
                case .minimize:
                    self.setupLayoutMinimize()
                case .maximize:
                    self.setupLayoutMaximize()
                }
            }
            .store(in: &actionCancellables)
    }
    
    // MARK: Interfaces
    
    internal func stopPlaying() {
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        player = nil
        playerLayer.removeFromSuperlayer()
        dataCancellables.cancelAll()
    }
    
    internal func play() {
        guard let player else { return }
        player.play()
        
        #if DEBUG
            print("Video url:", urlString)
        #endif
    }
    
    internal func pause() {
        guard let player else { return }
        player.pause()
    }
    
    internal func replay() {
        guard let player else { return }
        player.seek(to: .zero)
        player.play()
    }
    
    internal func goForward() {
        guard let player,
              let duration = player.currentItem?.duration else { return }
        let playerCurrentTime: Float64 = CMTimeGetSeconds(player.currentTime())
        let newTime: Float64 = playerCurrentTime + seekDuration
        guard newTime < CMTimeGetSeconds(duration) else { return }
        let time: CMTime = CMTimeMake(value: Int64(newTime), timescale: 1)
        player.seek(to: time)
    }
    
    internal func goBackward() {
        guard let player else { return }
        let playerCurrentTime = CMTimeGetSeconds(player.currentTime())
        var newTime: Float64 = playerCurrentTime - seekDuration
        newTime = newTime < 0.0 ? 0.0 : newTime
        let time: CMTime = CMTimeMake(value: Int64(newTime), timescale: 1)
        player.seek(to: time)
    }
    
    internal func resizePlayerLayer(with size: CGSize) {
        if playerLayer.bounds.width > size.width ||
            playerLayer.bounds.height > size.height {
            playerLayer.frame = CGRectMake(0.0, 0.0, size.width, size.height)
        } else {
            // Disable `CALayer` implicit animations
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            playerLayer.frame = CGRectMake(0.0, 0.0, size.width, size.height)
            CATransaction.commit()
        }
    }
}
