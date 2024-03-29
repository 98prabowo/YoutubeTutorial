//
//  Menu.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 02/02/23.
//

import Combine
import UIKit

internal enum Menu: String, CaseIterable, Hashable {
    case home
    case trending
    case subscriptions
    
    internal var title: String {
        switch self {
        case .home:
            return "Home"
        case .trending:
            return "Trending"
        case .subscriptions:
            return "Subscriptions"
        }
    }
    
    internal var icon: UIImage? {
        switch self {
        case .home:
            return UIImage(systemName: "house.fill")
        case .trending:
            return UIImage(systemName: "flame.fill")
        case .subscriptions:
            return UIImage(systemName: "play.square.stack.fill")
        }
    }
    
    internal var service: Future<[Video], NetworkError> {
        FirebaseManager.shared.fetchAllData(self)
    }
}
