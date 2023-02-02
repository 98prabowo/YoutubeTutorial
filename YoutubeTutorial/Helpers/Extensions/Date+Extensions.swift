//
//  Date+Extensions.swift
//  YoutubeTutorial
//
//  Created by Dimas Prabowo on 01/02/23.
//

import Foundation

extension Date {
    /// Get time distance to designated date.
    ///
    /// - Parameters:
    ///   - date: A `Date` target to calculate the distance from self.
    internal func getDateDistance(to date: Date = Date()) -> String? {
        let dateComponentsFormatter = DateComponentsFormatter()
        dateComponentsFormatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth, .month, .year]
        dateComponentsFormatter.maximumUnitCount = 1
        dateComponentsFormatter.unitsStyle = .full
        return dateComponentsFormatter.string(from: self, to: date)
    }
    
    internal static var mockLoveStoryDate: Date? {
        // Specify date components
        var dateComponents = DateComponents()
        dateComponents.year = 2009
        dateComponents.month = 6
        dateComponents.day = 17
        dateComponents.timeZone = TimeZone(abbreviation: "WIT") // Jakarta Standard Time

        // Create date from components
        let userCalendar = Calendar(identifier: .gregorian) // since the components above (like year 1980) are for Gregorian
        return userCalendar.date(from: dateComponents)
    }
    
    internal static var mockBlankSpaceDate: Date? {
        // Specify date components
        var dateComponents = DateComponents()
        dateComponents.year = 2014
        dateComponents.month = 11
        dateComponents.day = 11
        dateComponents.timeZone = TimeZone(abbreviation: "WIT") // Jakarta Standard Time

        // Create date from components
        let userCalendar = Calendar(identifier: .gregorian) // since the components above (like year 1980) are for Gregorian
        return userCalendar.date(from: dateComponents)
    }
    
    internal static var mockBadBloodDate: Date? {
        // Specify date components
        var dateComponents = DateComponents()
        dateComponents.year = 2015
        dateComponents.month = 5
        dateComponents.day = 18
        dateComponents.timeZone = TimeZone(abbreviation: "WIT") // Jakarta Standard Time

        // Create date from components
        let userCalendar = Calendar(identifier: .gregorian) // since the components above (like year 1980) are for Gregorian
        return userCalendar.date(from: dateComponents)
    }
    
    internal static var mockLookWhatDate: Date? {
        // Specify date components
        var dateComponents = DateComponents()
        dateComponents.year = 2017
        dateComponents.month = 8
        dateComponents.day = 28
        dateComponents.timeZone = TimeZone(abbreviation: "WIT") // Jakarta Standard Time

        // Create date from components
        let userCalendar = Calendar(identifier: .gregorian) // since the components above (like year 1980) are for Gregorian
        return userCalendar.date(from: dateComponents)
    }
    
    internal static var mockShakeItOffDate: Date? {
        // Specify date components
        var dateComponents = DateComponents()
        dateComponents.year = 2014
        dateComponents.month = 8
        dateComponents.day = 19
        dateComponents.timeZone = TimeZone(abbreviation: "WIT") // Jakarta Standard Time

        // Create date from components
        let userCalendar = Calendar(identifier: .gregorian) // since the components above (like year 1980) are for Gregorian
        return userCalendar.date(from: dateComponents)
    }
    
    internal static var mockAntiHeroDate: Date? {
        // Specify date components
        var dateComponents = DateComponents()
        dateComponents.year = 2022
        dateComponents.month = 10
        dateComponents.day = 21
        dateComponents.timeZone = TimeZone(abbreviation: "WIT") // Jakarta Standard Time

        // Create date from components
        let userCalendar = Calendar(identifier: .gregorian) // since the components above (like year 1980) are for Gregorian
        return userCalendar.date(from: dateComponents)
    }
}
