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

extension Channel {
    internal init?(_ dictionary: [String: Any]) {
        guard let name = dictionary["name"] as? String,
              let profileImageName = dictionary["profile_image_name"] as? String else { return nil }
        self.name = name
        self.profileImageName = profileImageName
    }
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
