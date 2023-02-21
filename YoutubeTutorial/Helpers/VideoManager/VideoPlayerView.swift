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
        case maximize
    }
    
    // MARK: UI Components
    
    internal let controlView: VideoControllerView = {
        let view = VideoControllerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.accessibilityIdentifier = "VideoPlayerView.controlView"
        return view
    }()
    
    // MARK: Properties
    
    private lazy var asset: AVURLAsset? = {
        guard let url = URL(string: self.urlString) else { return nil }
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
    
    internal let screenState = CurrentValueSubject<ScreenState, Never>(.noScreen)
    
    private let seekDuration: Float64 = 10 // seconds
    
    private lazy var playerLayer = AVPlayerLayer(player: player)
    
    private var cancellables = Set<AnyCancellable>()
    
    internal let urlString: String
    
    // MARK: Lifecycles
    
    internal init(for urlString: String) {
        self.urlString = urlString
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
    
    deinit {
        player = nil
    }
    
    // MARK: Layouts
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
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
    
    // MARK: Implementations
    
    private func bindData() {
        guard let player else { return }
        player.periodicTimePublisher()
            .sink { [controlView] time in
                guard time.value == 0 else { return }
                controlView.state.send(.playing(isHidden: true, source: .system))
            }
            .store(in: &cancellables)
        
        player.finishPlayPublisher()
            .sink { [controlView] in
                controlView.state.send(.finished(isHidden: false))
            }
            .store(in: &cancellables)
    }
    
    private func bindAction() {
        tap()
            .sink { [controlView, screenState] in
                switch screenState.value {
                case .normal, .maximize:
                    var state = controlView.state.value
                    state.toggleHidden()
                    controlView.state.send(state)
                    
                case .noScreen, .minimize:
                    break
                }
            }
            .store(in: &cancellables)
        
        controlView.action
            .receive(on: DispatchQueue.main)
            .sink { [weak self] action in
                guard let self else { return }
                switch action {
                case .emptyAction:
                    break
                case .didTapMinimizeButton:
                    self.screenState.send(.minimize)
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
            .store(in: &cancellables)
        
        screenState
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self else { return }
                
                switch state {
                case .noScreen:
                    self.setupLayoutNoScreen()
                    self.pause()
                    
                case .normal:
                    self.setupLayoutNormal()
                    let state = self.controlView.state.value
                    self.controlView.state.send(state)
                    
                case .maximize:
                    self.pinSubview(self.controlView)
                    var state = self.controlView.state.value
                    state.showControlPanel()
                    self.controlView.state.send(state)
                    
                case .minimize:
                    self.setupLayoutMinimize()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: Interfaces
    
    internal func play() {
        guard let player else { return }
        player.play()
        print("Video url:", urlString)
    }
    
    internal func pause() {
        guard let player else { return }
        player.pause()
    }
    
    internal func replay() {
        guard let player else { return }
        player.seek(to: CMTime.zero)
        player.play()
    }
    
    internal func goForward() {
        guard let player,
              let duration = player.currentItem?.duration else { return }
        let playerCurrentTime: Float64 = CMTimeGetSeconds(player.currentTime())
        let newTime: Float64 = playerCurrentTime + seekDuration
        guard newTime < CMTimeGetSeconds(duration) else { return }
        let time: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
        player.seek(to: time)
    }
    
    internal func goBackward() {
        guard let player else { return }
        let playerCurrentTime = CMTimeGetSeconds(player.currentTime())
        var newTime: Float64 = playerCurrentTime - seekDuration
        newTime = newTime < 0.0 ? 0.0 : newTime
        let time: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
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
