//
//  TimeInterval+Extensions.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 13/02/23.
//

import Foundation

extension TimeInterval {
    /// Helpers to get `TimeInterval` for specific minutes
    internal static var minutes: (Int) -> TimeInterval = {
        return Double($0 * 60)
    }
    
    /// Helpers to get `TimeInterval` for specific hours
    internal static var hours: (Int) -> TimeInterval = {
        return Double($0) * .minutes(60)
    }
    
    /// Helpers to get `TimeInterval` for specific days
    internal static var days: (Int) -> TimeInterval = {
        return Double($0) * .hours(24)
    }
    
    internal var toInt: Int {
        let roundedValue = rounded(.toNearestOrEven)
        return Int(exactly: roundedValue) ?? 0
    }
}
