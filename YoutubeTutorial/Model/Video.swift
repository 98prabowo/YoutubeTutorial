//
//  Video.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 31/01/23.
//

import Foundation

internal struct Video {
    internal let thumbnail: String
    internal let title: String
    internal let numberOfViews: Int
    internal let uploadDate: Date?
    internal let channel: Channel
    
    internal var subtitle: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formattedViews = formatter.string(from: NSNumber(integerLiteral: numberOfViews)) ?? "0"
        var uploadDistance = String()
        if let uploadDate = uploadDate,
           let distanceUpload = uploadDate.getDateDistance() {
            uploadDistance = " • \(distanceUpload) ago"
        }
        return "\(channel.name) • \(formattedViews)\(uploadDistance)"
    }
}

extension Array where Element == Video {
    internal static var mock: [Video] {
        [
            Video(
                thumbnail: "taylor_swift_blank_space",
                title: "Taylor Swift - Blank Space",
                numberOfViews: 3_095_839_684,
                uploadDate: .mockBlankSpaceDate,
                channel: .mock
            ),
            Video(
                thumbnail: "taylor_swift_bad_blood",
                title: "Taylor Swift - Bad Blood featuring Kendrick Lamar",
                numberOfViews: 1_534_177_502,
                uploadDate: .mockBadBloodDate,
                channel: .mock
            ),
            Video(
                thumbnail: "taylor_swift_look_what_you_made_me_do",
                title: "Taylor Swift - Look What You Made Me Do",
                numberOfViews: 1_380_031_891,
                uploadDate: .mockLookWhatDate,
                channel: .mock
            ),
            Video(
                thumbnail: "taylor_swift_love_story",
                title: "Taylor Swift - Love Story",
                numberOfViews: 663_361_010,
                uploadDate: .mockLoveStoryDate,
                channel: .mock
            ),
            Video(
                thumbnail: "taylor_swift_shake_it_off",
                title: "Taylor Swift - Shake It Off",
                numberOfViews: 3_247_355_635,
                uploadDate: .mockShakeItOffDate,
                channel: .mock
            ),
            Video(
                thumbnail: "taylor_swift_anti_hero",
                title: "Taylor Swift - Anti-Hero",
                numberOfViews: 100_423_166,
                uploadDate: .mockAntiHeroDate,
                channel: .mock
            )
        ]
    }
}
