//
//  EndPoint.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 13/02/23.
//

import Foundation

internal enum EndPoint {
    case home
    case trending
    case subscriptions
    case account
    case video
    
    private var baseURL: String { "https://s3-us-west-2.amazonaws.com/youtubeassets" }
    
    private var fileType: String { "json" }
    
    private var videoURLs: [String] {
        [
            "https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
            "https://storage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
            "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
            "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
            "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
            "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
            "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4",
            "https://storage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4",
            "https://storage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4"
        ]
    }
    
    internal var url: String {
        switch self {
        case .home:
            return baseURL + "/home." + fileType
        case .trending:
            return baseURL + "/trending." + fileType
        case .subscriptions:
            return baseURL + "/subscriptions." + fileType
        case .account:
            return baseURL + "/account." + fileType
        case .video:
            return videoURLs.randomElement() ?? "https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
        }
    }
}
