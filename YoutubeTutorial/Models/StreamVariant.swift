//
//  StreamVariant.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 17/03/23.
//

import Foundation
import CoreGraphics

internal enum VideoDefinition: Hashable {
    case auto(url: URL)
    case r144p(url: URL)
    case r240p(url: URL)
    case r360p(url: URL)
    case r480p(url: URL)
    case r720p(url: URL)
    case r1080p(url: URL)
    case r1440p(url: URL)
    case r4k(url: URL)
    case r8k(url: URL)
    
    internal static func transform(_ size: CGSize, playlistURL: URL, url: URL) -> Self {
        switch (size.width, size.height) {
        case (_, 0...190):
            return .r144p(url: url)
        case (_, 200...290):
            return .r240p(url: url)
        case (_, 300...390):
            return .r360p(url: url)
        case (_, 400...490):
            return .r480p(url: url)
        case (_, 600...890):
            return .r720p(url: url)
        case (_, 900...1200):
            return .r1080p(url: url)
        case (_, 1300...1800):
            return .r1440p(url: url)
        case (3000...6000, 1900...):
            return .r4k(url: url)
        case (7000..., 1900...):
            return .r8k(url: url)
        default:
            return .auto(url: playlistURL)
        }
    }
    
    internal var text: String {
        switch self {
        case .r144p:
            return "144p"
        case .r240p:
            return "240p"
        case .r360p:
            return "360p"
        case .r480p:
            return "480p"
        case .r720p:
            return "720p"
        case .r1080p:
            return "1080p"
        case .r1440p:
            return "1440p"
        case .r4k:
            return "4k"
        case .r8k:
            return "8k"
        case .auto:
            return "Auto"
        }
    }
    
    internal var url: URL {
        switch self {
        case let .r144p(url):
            return url
        case let .r240p(url):
            return url
        case let .r360p(url):
            return url
        case let .r480p(url):
            return url
        case let .r720p(url):
            return url
        case let .r1080p(url):
            return url
        case let .r1440p(url):
            return url
        case let .r4k(url):
            return url
        case let .r8k(url):
            return url
        case let .auto(url):
            return url
        }
    }
}

internal struct StreamVariant: Hashable {
    internal let maxBandwidth: Double
    internal let averageBandwidth: Double
    internal let resolution: CGSize
    internal let playlistURL: URL
    internal let url: URL
    
    internal func hash(into hasher: inout Hasher) {
        hasher.combine("\(maxBandwidth) url.absoluteString")
    }
    
    internal var definition: VideoDefinition {
        VideoDefinition.transform(resolution, playlistURL: playlistURL, url: url)
    }
}

internal struct RawPlaylist: Equatable {
    internal let urlPlaylist: String
    internal let content: String
    
    internal var streamResolutions: [StreamVariant] {
        var variants = [StreamVariant]()
        var resolution: (maxBandwidth: Double, averageBandwidth: Double, resolution: CGSize)?
        let urlScheme: String? = urlPlaylist.components(separatedBy: "://").first
        let urlMain: String? = urlPlaylist.components(separatedBy: "//").last
        let urlComponents: [String]? = urlMain?.components(separatedBy: "/")
        let urlHost: String? = urlComponents?.first
        let urlPath: String? = urlComponents?.dropFirst().dropLast().joined(separator: "/")
        
        content.enumerateLines { line, _ in
            let infoline: String = line.replacingOccurrences(of: "#EXT-X-STREAM-INF:", with: "")
            let infoItems: [String] = infoline.components(separatedBy: ",")
            let bandwidthItem: String? = infoItems.first { $0.contains("BANDWIDTH") }
            let resolutionItem: String? = infoItems.first { $0.contains("RESOLUTION") }
            
            let endpoint: String? = !line.isEmpty && !line.contains("#") && !line.contains("EXT") ? line : nil
            
            if let bandwidth = bandwidthItem?.components(separatedBy: "=").last,
               let numericBandwidth = Double(bandwidth),
               let resolutionSize = resolutionItem?.components(separatedBy: "=").last?.components(separatedBy: "x"),
               let strignWidth = resolutionSize.first,
               let stringHeight = resolutionSize.last,
               let width = Double(strignWidth),
               let height = Double(stringHeight) {
                resolution = (numericBandwidth, numericBandwidth, CGSizeMake(width, height))
            }
            
            if let resolutionData = resolution,
               let urlScheme,
               let urlHost,
               let urlPath,
               let endpoint {
                var components = URLComponents()
                components.scheme = urlScheme
                components.host = urlHost
                components.path = "/" + urlPath + "/" + endpoint

                guard let url = components.url,
                      let playlistURL = URL(string: urlPlaylist) else { return }
                
                variants.append(
                    StreamVariant(
                        maxBandwidth: resolutionData.maxBandwidth,
                        averageBandwidth: resolutionData.averageBandwidth,
                        resolution: resolutionData.resolution,
                        playlistURL: playlistURL,
                        url: url
                    )
                )
                resolution = nil
            }
        }
        
        return variants
            .sorted {
                $0.resolution.width * $0.resolution.height <
                    $1.resolution.width * $1.resolution.height
            }
    }
}
