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
}
