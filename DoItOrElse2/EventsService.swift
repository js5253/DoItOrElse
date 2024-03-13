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
    var container: ModelContainer? = nil;
    static let shared: EventsService = {
        let instance = EventsService()
        instance.initialize()
        // setup code
        return instance
    }()
    func createNewCategory(name: String) async {
        await container?.mainContext.insert(Category(name: "Jose"))
        do {
            try await container?.mainContext.save()
            
            try await print(container?.mainContext.fetch(FetchDescriptor<Category>()))
        } catch {
            print(error)
        }

        
    }
    func getReminderById(_ identifier: String) -> EKReminder {
        return store?.calendarItem(withIdentifier: identifier) as! EKReminder
    }
    func attachCategoryToEvent(id: String) {
        
    }
    func initialize() {
        store = EKEventStore();
        do {
            container = try ModelContainer(for: Category.self);
        } catch {
            print(error)
        }
//        do { try to initialize SwiftData from here, somehow ;-;
//            let container = try ModelContainer(for:Category.self);
//            context = container.mainContext;
//        } catch {
//            
//        }
        store?.requestFullAccessToReminders() { (granted, error) in}
                }

    func getAllReminders() async -> [EKReminder]? {
        print("Get All events...")
        
        let predForAllItems = self.store!.predicateForReminders(in: [self.store!.defaultCalendarForNewReminders()!]);
        return await getRemindersWithPredicate(predicate: predForAllItems)

    }
    func getRemindersWithPredicate(predicate: NSPredicate) async -> [EKReminder]? {
        await withCheckedContinuation { continuation in
            guard let cal = self.store!.defaultCalendarForNewReminders() else {
                print("Error getting default calendar")
                return
            };
            let predForAllItems = self.store!.predicateForReminders(in: [cal]);
            self.store!.fetchReminders(matching: predForAllItems, completion: {
                rem in
                continuation.resume(returning: rem)
            })

        }
        
    }
    func getFutureReminders(predicate: NSPredicate) async -> [EKReminder]?{
        let predForFutureReminders = self.store!.predicateForReminders(in: [self.store!.defaultCalendarForNewReminders()!])
        return await getRemindersWithPredicate(predicate: predForFutureReminders)
    }
    func getAmountOwed() async -> Int {
        let reminders = await getAllReminders();
        
        let amountOwed = reminders?.reduce(0, {x, _ in x + 20});
        
        return amountOwed ?? 0
    }
    func addReminder(todoName: String, todoDueDate: Date) {
        let ev = EKReminder(eventStore: store!)
        ev.title = todoName;
        ev.dueDateComponents = Calendar.current.dateComponents(in: .current, from: todoDueDate);
        ev.calendar = store!.defaultCalendarForNewReminders()
        do {
            try store!.save(ev, commit: true)
        } catch {
            print(error)
        }
    }
}
