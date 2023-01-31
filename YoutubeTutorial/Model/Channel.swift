//
//  Channel.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 01/02/23.
//

import Foundation

internal struct Channel {
    internal let name: String
    internal let profile: String
}

extension Channel {
    internal static var mock: Channel {
        Channel(
            name: "TaylorSwiftVEVO",
            profile: "taylor_swift_profile"
        )
    }
}
