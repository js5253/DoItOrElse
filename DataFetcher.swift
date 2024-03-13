//
//  DataFetcher.swift
//  DoItOrElse2
//
//  Created by jose on 3/12/24.
//

import Foundation
import EventKit

class DataFetcher {
    var store: EKEventStore? = nil;
    func getEvents() -> [EKReminder]? {
        store = EKEventStore()
        var reminders: [EKReminder]?
        
        
        guard let cal = self.store!.defaultCalendarForNewReminders() else {
            print("Error getting default calendar")
            return nil
        };
        let predForAllItems = self.store!.predicateForReminders(in: [cal]);
        self.store!.fetchReminders(matching: predForAllItems, completion: {
            rem in
            reminders = rem
        })

        return reminders
    }
}
