//
//  VideoPlayerPublisherImplementations.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 14/02/23.
//

import AVFoundation
import Combine

extension AVPlayer {
    internal func periodicTimePublisher(forInterval interval: CMTime = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))) -> AnyPublisher<CMTime, Never> {
        VideoPlayerTimePublisher(self, forInterval: interval)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    internal func finishPlayPublisher() -> AnyPublisher<Void, Never> {
        VideoPlayerFinishPublisher(self)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
