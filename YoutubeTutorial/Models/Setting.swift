//
//  Setting.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 02/02/23.
//

import UIKit

internal enum Setting: CaseIterable {
    case setting
    case termPolicy
    case feedback
    case help
    case account
    case cancel
    
    internal var icon: UIImage? {
        switch self {
        case .setting:
            return UIImage(systemName: "gearshape.fill")
        case .termPolicy:
            return UIImage(systemName: "lock.shield.fill")
        case .feedback:
            return UIImage(systemName: "exclamationmark.bubble.fill")
        case .help:
            return UIImage(systemName: "questionmark.circle.fill")
        case .account:
            return UIImage(systemName: "person.circle.fill")
        case .cancel:
            return UIImage(systemName: "xmark")
        }
    }
    
    internal var title: String {
        switch self {
        case .setting:
            return "Settings"
        case .termPolicy:
            return "Terms & Privacy Policy"
        case .feedback:
            return "Send Feedback"
        case .help:
            return "Help"
        case .account:
            return "Switch Account"
        case .cancel:
            return "Cancel"
        }
    }
}
