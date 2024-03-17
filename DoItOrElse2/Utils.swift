//
//  Utils.swift
//  DoItOrElse2
//
//  Created by jose on 3/13/24.
//

import Foundation

class Utils {
    static func dateAlreadyPassed(_ date: Date) -> Bool {
        let currentDate = Date()
        return date < currentDate
    }
    static func formatDate(_ date: Date) -> String {
        return ""
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

}
