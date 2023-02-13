//
//  Channel.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 01/02/23.
//

import Foundation

internal struct Channel: Hashable {
    internal let name: String
    internal let profileImageName: String
}

extension Channel: Codable {
    internal enum CodingKeys: String, CodingKey {
        case name
        case profileImageName = "profile_image_name"
    }
}

extension Channel {
    internal static var mock: Channel {
        Channel(
            name: "TaylorSwiftVEVO",
            profileImageName: "taylor_swift_profile"
        )
    }
}
