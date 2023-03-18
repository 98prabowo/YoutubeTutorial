//
//  VideoButtonType.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 06/03/23.
//

import Combine
import UIKit

internal enum VideoButtonType {
    case lock
    case rate
    case resolution
    case custom(Template)
        
    // MARK: Value Types
    
    internal struct Template {
        internal let title: String
        internal let image: UIImage?
        internal let action: () -> Void
    }
    
    // MARK: Interfaces
    
    internal static let btnSize: CGSize = CGSizeMake(20.0, 20.0)
    
    internal var title: String {
        switch self {
        case .lock:
            return "Lock"
        case .rate:
            return "Speed"
        case .resolution:
            return "Resolution"
        case let .custom(template):
            return template.title
        }
    }
    
    internal var image: UIImage? {
        switch self {
        case .lock:
            return UIImage(systemName: "lock")
        case .rate:
            return UIImage(systemName: "speedometer")
        case .resolution:
            return UIImage(systemName: "gearshape")
        case let .custom(template):
            return template.image
        }
    }
}
