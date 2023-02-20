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
    // MARK: UI Components
    
    private let controlView: VideoControllerView = {
        let view = VideoControllerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: Properties
    
    private lazy var player: AVPlayer? = {
        guard let url = URL(string: self.urlString) else { return nil }
        let player = AVPlayer(url: url)
        return player
    }()
    
    private lazy var playerLayer = AVPlayerLayer(player: player)
    
    private var cancellables = Set<AnyCancellable>()
    
    internal let urlString: String
    
    // MARK: Lifecycles
    
    internal init(for urlString: String) {
        self.urlString = urlString
        super.init(frame: .zero)
        backgroundColor = .black
        setupLayout()
        bindData()
        bindAction()
    }
    
    required internal init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Layouts
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
    
    private func setupLayout() {
        layer.addSublayer(playerLayer)
        pinSubview(controlView)
    }
    
    // MARK: Implementations
    
    private func bindData() {
        guard let player else { return }
        player.periodicTimePublisher()
            .sink { [controlView] time in
                if time.value == 0 {
                    controlView.state.send(.playing(isHidden: true))
                }
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
            .sink { [controlView] in
                controlView.state.send(.playing(isHidden: false))
            }
            .store(in: &cancellables)
        
        controlView.action
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] action in
                guard let self else { return }
                switch action {
                case .didTapPlayButton:
                    self.play()
                case .didTapPauseButton:
                    self.pause()
                case .didTapReplayButton:
                    self.replay()
                }
            }
            .store(in: &cancellables)
    }
    
    internal func play() {
        guard let player else { return }
        player.play()
        print("Video url:", urlString)
    }
    
    private func pause() {
        guard let player else { return }
        player.pause()
    }
    
    private func replay() {
        guard let player else { return }
        player.seek(to: CMTime.zero)
        player.play()
    }
}
