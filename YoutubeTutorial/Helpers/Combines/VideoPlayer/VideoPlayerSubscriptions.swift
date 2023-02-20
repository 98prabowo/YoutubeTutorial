//
//  VideoPlayerSubscriptions.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 14/02/23.
//

import AVFoundation
import Combine

internal final class VideoPlayerTimeSubscription<SubscriberType: Subscriber>: Combine.Subscription where SubscriberType.Input == CMTime, SubscriberType.Failure == Never {
    internal var player: AVPlayer?
    internal var observer: Any?
    
    internal init(subscriber: SubscriberType, player: AVPlayer, forInterval interval: CMTime) {
        self.player = player
        observer = player.addPeriodicTimeObserver(forInterval: interval, queue: nil) { time in
            _ = subscriber.receive(time)
        }
    }
    
    internal func request(_ demand: Subscribers.Demand) {}
    
    internal func cancel() {
        if let observer = observer {
            player?.removeTimeObserver(observer)
        }
        observer = nil
        player = nil
    }
}

internal final class VideoPlayerFinishSubscription<SubscriberType: Subscriber>: Combine.Subscription where SubscriberType.Input == Void, SubscriberType.Failure == Never {
    private var subscriber: SubscriberType?
    internal var player: AVPlayer?
    
    internal init(subscriber: SubscriberType, player: AVPlayer) {
        self.subscriber = subscriber
        self.player = player
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleEvent),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem
        )
    }
    
    internal func request(_ demand: Subscribers.Demand) {}
    
    internal func cancel() {
        player = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleEvent(_ sender: NSNotification) {
        _ = subscriber?.receive(())
    }
}
