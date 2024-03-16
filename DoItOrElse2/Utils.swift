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
    func isDateMoreThan24HoursBeforeNow(date: Date) -> Bool {
        let currentDate = Date() // Current date and time
        let calendar = Calendar.current

        // Calculate the difference in hours between the current date and the given date
        let hoursDifference = calendar.dateComponents([.hour], from: date, to: currentDate).hour ?? 0

        // Check if the difference is more than 24 hours
        return hoursDifference > 24
    }
}
