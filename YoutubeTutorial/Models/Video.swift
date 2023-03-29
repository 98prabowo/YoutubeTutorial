//
//  Video.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 31/01/23.
//

import Foundation

internal struct Video: Hashable {
    internal let id: Int
    internal let title: String
    internal let numberOfViews: Int
    internal let thumbnailImageName: String
    internal let videoURL: String
    internal let uploadDate: Date
    internal let channel: Channel
    
    internal var subtitle: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formattedViews = formatter.string(from: NSNumber(integerLiteral: numberOfViews)) ?? "0"
        let uploadDistance = "\(uploadDate.getDateDistance()) ago"
        return "\(channel.name) • \(formattedViews) • \(uploadDistance)"
    }
}

extension Video {
    internal init?(_ dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? Int,
              let title = dictionary["title"] as? String,
              let numberOfViews = dictionary["number_of_views"] as? Int,
              let thumbnailImageName = dictionary["thumbnail_image_name"] as? String,
              let videoURL = dictionary["video_url"] as? String,
              let duration = dictionary["duration"] as? Int,
              let channelDict = dictionary["channel"] as? [String: Any],
              let channel = Channel(channelDict) else { return nil }
        self.id = id
        self.title = title
        self.numberOfViews = numberOfViews
        self.thumbnailImageName = thumbnailImageName
        self.videoURL = videoURL
        self.uploadDate = Date(timeIntervalSinceNow: .days(duration))
        self.channel = channel
    }
}

extension Video: Codable {
    internal init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = 0
        title = try container.decode(String.self, forKey: .title)
        numberOfViews = try container.decode(Int.self, forKey: .numberOfViews)
        thumbnailImageName = try container.decode(String.self, forKey: .thumbnailImageName)
        channel = try container.decode(Channel.self, forKey: .channel)
        videoURL = "" // Unimplemented at back end
        
        let duration = try container.decode(Int.self, forKey: .duration)
        uploadDate = Date(timeIntervalSinceNow: .days(duration))
    }
    
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(numberOfViews, forKey: .numberOfViews)
        try container.encode(thumbnailImageName, forKey: .thumbnailImageName)
        try container.encode(channel, forKey: .channel)
        
        let duration: Int = uploadDate.get(.day)
        try container.encode(duration, forKey: .duration)
    }
    
    internal enum CodingKeys: String, CodingKey {
        case title
        case numberOfViews = "number_of_views"
        case thumbnailImageName = "thumbnail_image_name"
        case channel
        case duration
    }
}

extension Array where Element == Video {
    internal static var mock: [Video] {
        [
            Video(
                id: 0,
                title: "Taylor Swift - Blank Space",
                numberOfViews: 3_095_839_684,
                thumbnailImageName: "taylor_swift_blank_space",
                videoURL: "",
                uploadDate: .mockBlankSpaceDate,
                channel: .mock
            ),
            Video(
                id: 1,
                title: "Taylor Swift - Bad Blood featuring Kendrick Lamar",
                numberOfViews: 1_534_177_502,
                thumbnailImageName: "taylor_swift_bad_blood",
                videoURL: "",
                uploadDate: .mockBadBloodDate,
                channel: .mock
            ),
            Video(
                id: 2,
                title: "Taylor Swift - Look What You Made Me Do",
                numberOfViews: 1_380_031_891,
                thumbnailImageName: "taylor_swift_look_what_you_made_me_do",
                videoURL: "",
                uploadDate: .mockLookWhatDate,
                channel: .mock
            ),
            Video(
                id: 3,
                title: "Taylor Swift - Love Story",
                numberOfViews: 663_361_010,
                thumbnailImageName: "taylor_swift_love_story",
                videoURL: "",
                uploadDate: .mockLoveStoryDate,
                channel: .mock
            ),
            Video(
                id: 4,
                title: "Taylor Swift - Shake It Off",
                numberOfViews: 3_247_355_635,
                thumbnailImageName: "taylor_swift_shake_it_off",
                videoURL: "",
                uploadDate: .mockShakeItOffDate,
                channel: .mock
            ),
            Video(
                id: 5,
                title: "Taylor Swift - Anti-Hero",
                numberOfViews: 100_423_166,
                thumbnailImageName: "taylor_swift_anti_hero",
                videoURL: "",
                uploadDate: .mockAntiHeroDate,
                channel: .mock
            )
        ]
    }
}
