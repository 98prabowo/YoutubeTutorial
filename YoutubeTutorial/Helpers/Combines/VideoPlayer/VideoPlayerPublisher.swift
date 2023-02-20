//
//  VideoPlayerPublisher.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 14/02/23.
//

import AVFoundation
import Combine

internal struct VideoPlayerTimePublisher: Publisher {
    typealias Output = CMTime
    typealias Failure = Never
    
    internal var player: AVPlayer
    internal var interval: CMTime
    
    internal init(_ player: AVPlayer, forInterval interval: CMTime) {
        self.player = player
        self.interval = interval
    }
    
    internal func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = VideoPlayerTimeSubscription(
            subscriber: subscriber,
            player: player,
            forInterval: interval
        )
        subscriber.receive(subscription: subscription)
    }
}

internal struct VideoPlayerFinishPublisher: Publisher {
    typealias Output = Void
    typealias Failure = Never
    
    internal var player: AVPlayer
    
    internal init(_ player: AVPlayer) {
        self.player = player
    }
    
    internal func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = VideoPlayerFinishSubscription(
            subscriber: subscriber,
            player: player
        )
        subscriber.receive(subscription: subscription)
    }
}
