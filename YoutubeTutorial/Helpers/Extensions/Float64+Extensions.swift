//
//  Float64+Extensions.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 24/02/23.
//

import Foundation

extension Float64 {
    internal var formattedDuration: String {
        let totalSeconds: Int = Int(self)
        let hours: Int = Int(self / 3600)
        let minutes: Int = Int(totalSeconds % 3600 / 60)
        let seconds: Int = Int((totalSeconds % 3600) % 60)
        
        if hours > 0 {
            return String(format: "%i:%02i:%02i", hours, minutes, seconds)
        } else {
            return String(format: "%02i:%02i", minutes, seconds)
        }
    }
}
