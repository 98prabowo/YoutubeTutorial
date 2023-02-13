//
//  VideoView.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 14/02/23.
//

import UIKit

internal class VideoView: UIView {
    // MARK: UI Components
    
    private let videoPlayer: VideoPlayerView = {
        let player = VideoPlayerView()
        player.translatesAutoresizingMaskIntoConstraints = false
        return player
    }()
    
    // MARK: Properties
    
    private let finalSize: CGSize = CGSize(width: 150.0, height: 100.0)
    
    private var windowUI: UIWindow? {
        guard let scene = UIApplication.shared.connectedScenes.first,
              let windowSceneDelegate = scene.delegate as? UIWindowSceneDelegate,
              let window = windowSceneDelegate.window else { return nil }
        return window
    }
    
    private let topInset: CGFloat
    
    // MARK: Lifecycles
    
    internal init(topInset: CGFloat) {
        self.topInset = topInset
        super.init(frame: .zero)
        backgroundColor = .white
    }
    
    required internal init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Layouts
    
    private func setupLayout() {
        guard let window = windowUI else { return }
        window.addSubview(self)
        addSubview(videoPlayer)
        
        frame = CGRectMake(
            window.frame.maxX - finalSize.width - 20.0,
            window.frame.maxY - finalSize.height - 30.0,
            finalSize.width,
            finalSize.height
        )
        
        // Use video pixel aspect ratio w: 16 h: 9 as thumbnail size
        let height: CGFloat = window.frame.width * (9 / 16)
        NSLayoutConstraint.activate([
            videoPlayer.topAnchor.constraint(equalTo: topAnchor, constant: topInset),
            videoPlayer.heightAnchor.constraint(equalToConstant: height),
            videoPlayer.leadingAnchor.constraint(equalTo: leadingAnchor),
            videoPlayer.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    // MARK: Interfaces
    
    internal func showVideoPlayer() {
        guard let window = windowUI else { return }
        setupLayout()
        UIView.animate(
            withDuration: 0.5,
            delay: 0.0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 1,
            options: .curveEaseOut
        ) { [weak self] in
            guard let self else { return }
            self.frame = window.frame
        } completion: { [videoPlayer] _ in
            videoPlayer.play(from: EndPoint.video.url)
        }
    }
}
