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
    
    static func year1950() -> Date {
        let dateComponents = NSDateComponents()
        dateComponents.year = 1950
        let calendar = NSCalendar.current
        return calendar.date(from: dateComponents as DateComponents)!
    }
    
    func age() -> Int {
        return Calendar.current.dateComponents([.year], from: self, to: Date()).year!
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
    
    func difference(from secondDate: Date) -> DateComponents {
        return Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: secondDate, to: self)
    }
    
    func mounthsDifference(from secondDate: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: secondDate, to: self).month!
    }
    
    func weeksDifference(from secondDate: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: secondDate, to: self).day! / 7
    }
    
    func daysDifference(from secondDate: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: secondDate, to: self).day!
    }
    
    func hoursDifference(from secondDate: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: secondDate, to: self).hour!
    }
    
    func minutesDifference(from secondDate: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: secondDate, to: self).minute!
    }
}
