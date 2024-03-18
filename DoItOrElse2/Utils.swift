//
//  Utils.swift
//  DoItOrElse2
//
//  Created by jose on 3/13/24.
//

import Foundation
import EventKit

class Utils {
    static func dateAlreadyPassed(_ date: Date) -> Bool {
        let currentDate = Date()
        return date < currentDate
    }
    static func isDateMoreThan24HoursBeforeNow(date: Date) -> Bool {
        let currentDate = Date() // Current date and time
        let calendar = Calendar.current

        // Calculate the difference in hours between the current date and the given date
        let hoursDifference = calendar.dateComponents([.hour], from: date, to: currentDate).hour ?? 0

        // Check if the difference is more than 24 hours
        return hoursDifference > 24
    }
    static func getDateFiveHoursBeforeEndOfToday() -> Date? {
        let calendar = Calendar.current
        let now = Date()
        
        // Get the end of today
        if let endOfToday = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: now) {
            // Subtract 5 hours from the end of today
            let date = calendar.date(byAdding: .hour, value: -5, to: endOfToday)
            print(date)
            return date
        }
        
        return nil
    }
    static func getRandomHeading() -> String {
        let headings = ["Welcome back", "Welcome to the Journey", "Rise and Shine"]
        return headings[Int.random(in:0...(headings.count - 1))]
    }
    static func hoursLeftInDay() -> Int? {
        // Get the current calendar and current date
        let calendar = Calendar.current
        let currentDate = Date()
        
        let currentHour = calendar.component(.hour, from: currentDate);
        
        return 24 - currentHour;

    }
    static func formatSecondsIntoString(_ seconds: Int) -> String {
        var result = ""
        let individual_seconds = seconds % 60;
        let minutes = Int(seconds / 60);
        
        result += String(minutes)
        result += "m "
        
        result += String(individual_seconds)
        result += "s"
        
        return result
    }
    static func getTimeIntervalToEndOfWeek() -> TimeInterval? {
        let calendar = Calendar.current
        let now = Date()
        
        if let endOfWeek = calendar.date(bySetting: .weekday, value: calendar.maximumRange(of: .weekday)?.upperBound ?? 7, of: now) {
            let timeInterval = endOfWeek.timeIntervalSince(now)
            return timeInterval
        }
        
        return nil
    }
    static func daysSinceCreation(_ reminder: EKReminder) -> Int? {
        guard let creationDate = reminder.creationDate else {
            return nil
        }
        
        let calendar = Calendar.current
        let currentDate = Date()
        
        let components = calendar.dateComponents([.day], from: creationDate, to: currentDate)
        return components.day
    }
}
