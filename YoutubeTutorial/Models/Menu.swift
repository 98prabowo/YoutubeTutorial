//
//  Menu.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 02/02/23.
//

import UIKit

internal enum Menu: CaseIterable {
    case home
    case trend
    case saved
    case profile
    
    internal var icon: UIImage? {
        switch self {
        case .home:
            return UIImage(systemName: "house.fill")
        case .trend:
            return UIImage(systemName: "flame.fill")
        case .saved:
            return UIImage(systemName: "play.square.stack.fill")
        case .profile:
            return UIImage(systemName: "person.fill")
        }
    }
}
