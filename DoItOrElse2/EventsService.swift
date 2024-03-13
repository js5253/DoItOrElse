//
//  DataFetcher.swift
//  DoItOrElse2
//
//  Created by jose on 3/12/24.
//

import Foundation
import EventKit
import SwiftData

@Model class Category {
    var name: String?
    init(name: String? = nil) {
        self.name = name
    }
}
@Model class AdditionalReminderInformation {
    var category: Category?
    
    init(category: Category? = nil) {
        self.category = category
    }
}

class EventsService {
    // really bad events service
    // note: this does not implement caching, or anything nice in particular.
    
    var store: EKEventStore? = nil;
    var context: ModelContext? = nil;
    static let shared: EventsService = {
        let instance = EventsService()
        instance.initialize()
        // setup code
        return instance
    }()
    func addCategory(name: String) {
        
    }
    func initialize() {
        store = EKEventStore();
//        do { try to initialize SwiftData from here, somehow ;-;
//            let container = try ModelContainer(for:Category.self);
//            context = container.mainContext;
//        } catch {
//            
//        }
        func requestAccessToReminders(completion: @escaping (Bool, Error?) -> Void) {
            store?.requestFullAccessToReminders() { (granted, error) in
                    DispatchQueue.main.async {
                        completion(granted, error)
                    }
                }
            }

    }
    func getAllReminders(completion: @escaping ([EKReminder]?) -> Void) -> Void {
        print("Get All events...")
        
        let predForAllItems = self.store!.predicateForReminders(in: [self.store!.defaultCalendarForNewReminders()!]);
        getRemindersWithPredicate(predicate: predForAllItems, completion: completion)

    }
    func getRemindersWithPredicate(predicate: NSPredicate, completion: @escaping ([EKReminder]?) -> Void) {
        print("Get events...")
        
        
        guard let cal = self.store!.defaultCalendarForNewReminders() else {
            print("Error getting default calendar")
            return
        };
        let predForAllItems = self.store!.predicateForReminders(in: [cal]);
        self.store!.fetchReminders(matching: predForAllItems, completion: {
            rem in
            completion(rem)
        })

    }
    func getTotal() {
        getAllReminders(completion: {
            reminders in
            reminders?.reduce(0, {x, _ in x + 20}) // FIXME: CHECK FOR ONLY ONES THAT PASSED
        })
    }
}
