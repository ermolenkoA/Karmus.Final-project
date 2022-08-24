//
//  DateExtention.swift
//  Karmus
//
//  Created by User on 8/22/22.
//

import Foundation

extension Date {
    func isGreaterThanDate(dateToCompare: Date) -> Bool {

        var isGreater = false

        if self.compare(dateToCompare) == ComparisonResult.orderedDescending {
            isGreater = true
        }

        return isGreater
    }

    func isLessThanDate(dateToCompare: Date) -> Bool {

        var isLess = false

        if self.compare(dateToCompare) == ComparisonResult.orderedAscending {
            isLess = true
        }

        return isLess
    }

    func equalToDate(dateToCompare: Date) -> Bool {

        var isEqualTo = false

        if self.compare(dateToCompare) == ComparisonResult.orderedSame {
            isEqualTo = true
        }

        return isEqualTo
    }


    func addHours(hoursToAdd: UInt) -> Date {
        let secondsInHours: TimeInterval = Double(hoursToAdd) * 60 * 60
        let dateWithHoursAdded: Date = self.addingTimeInterval(secondsInHours)

        return dateWithHoursAdded
    }
    
    func addMinutes(minutesToAdd: UInt) -> Date {
        let secondsInMinutes: TimeInterval = Double(minutesToAdd) * 60
        let dateWithMinutesAdded: Date = self.addingTimeInterval(secondsInMinutes)

        return dateWithMinutesAdded
    }
    
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
}