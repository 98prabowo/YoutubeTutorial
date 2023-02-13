//
//  VideoPlayerView.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 14/02/23.
//

import AVFoundation
import UIKit

internal class VideoPlayerView: UIView {
    // MARK: UI Components
    
    private let controlView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    // MARK: Lifecycles
    
    override internal init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
    }
    
    required internal init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Interfaces
    
    internal func play(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let player = AVPlayer(url: url)
        let playerLayer = AVPlayerLayer(player: player)
        layer.addSublayer(playerLayer)
        layer.masksToBounds = true
        playerLayer.frame = bounds
        player.play()
        print("Video url:", urlString)
    }
}
