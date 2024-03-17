//
//  DataFetcher.swift
//  DoItOrElse2
//
//  Created by jose on 3/12/24.
//

import Foundation
import EventKit
import SwiftData
import UserNotifications
enum FetchError: Error {
    case noMessages
}
@Model public class Category {
    @Attribute(.unique) var name: String
    
    init(name: String) {
        self.name = name
    }
}
@Model public class AdditionalReminderInformation {
    var category: Category?
    var reminderId: String
    var isAlreadyCounter: Bool
    
    init(category: Category? = nil) {
        self.category = category
        self.reminderId = ""
        self.isAlreadyCounter = false
    }
}

class DIReminder: EKReminder {
    public var extra: AdditionalReminderInformation?;
    public var reminder: EKReminder;
    init (_ reminder: EKReminder, extra: AdditionalReminderInformation?) {
        self.reminder = reminder;
        self.extra = extra;
    }
}
    
    class EventsService {
        // really bad events service
        // note: this does not implement caching, or anything nice in particular.
        
        
        var store: EKEventStore? = nil;
        var context: ModelContext? = nil;
        var container: ModelContainer? = nil;
        public let center = UNUserNotificationCenter.current()
        
        static let shared: EventsService = {
            let instance = EventsService()
            instance.initialize();
            // setup code
            return instance
        }()
        func createNewCategory(name: String) async -> Category? { // THIS SUCKS!!!
            await container?.mainContext.insert(Category(name: name))
            do {
                try await container?.mainContext.save()
                let predicate = #Predicate {(item: Category) in
                    item.name == name
                }
                var descriptor = FetchDescriptor<Category>(predicate: predicate)
                descriptor.fetchLimit = 1;
                return try await container?.mainContext.fetch(descriptor)[0];
                //            try await container
            } catch {
                print(error)
            }
            
            return nil;
            
        }
        func getCategories() async -> [Category] {
            print("Get categories")
            do {
                let data = try await container?.mainContext.fetch(FetchDescriptor<Category>())
                print("DATA", data)
                return data!
            } catch {
                return []
            }
        }
        
        func attachCategoryToEvent(id: String) {
            
        }
        func sendNotification() {
        }
        func initialize() {
            store = EKEventStore();
            do {
                try center.requestAuthorization(options: [.alert, .badge, .sound, .provisional], completionHandler: {
                    idk, err in
                    print("notifications:", idk, err)
                })
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
        func getReminderCount() -> Int {
            Task {
                return await getAllReminders()?.count;
            }
            return 0;
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
            func getRemindersPassed() async -> [Category] {
                var reminders = await getAllReminders();
//                reminders?.filter({
//                    data in
//                })
                return []
            }
        func getAllReminders() async -> [EKReminder]? {
                print("Get All events...")
                
                let predForAllItems = self.store!.predicateForReminders(in: [self.store!.defaultCalendarForNewReminders()!]);
                return await getRemindersWithPredicate(predicate: predForAllItems)

            }
        func getAmountOwed() async -> Int {
                let reminders = await getAllReminders();
                
                let amountOwed = reminders?.reduce(0, {x, _ in x + 20});
                
                return amountOwed ?? 0
            }
        func getReminderById(_ identifier: String) -> EKReminder {
            return store?.calendarItem(withIdentifier: identifier) as! EKReminder
        }
        func createReminder(todoName: String, todoDueDate: Date?, hasNotification: Bool) {
            let ev = EKReminder(eventStore: store!)
            ev.title = todoName;
            if let todoDueDate = todoDueDate {
                ev.dueDateComponents = Calendar.current.dateComponents(in: .current, from: todoDueDate);
            }
            ev.calendar = store!.defaultCalendarForNewReminders()
            do {
                try store!.save(ev, commit: true)
                
                if (hasNotification) {
                    let center = UNUserNotificationCenter.current()

                    Task {
                            try await center.requestAuthorization(options: [.alert, .sound, .badge])
                            
                            let content = UNMutableNotificationContent()
                            content.title = todoName
                            content.body = "fuckin dogshit ass app"
                            
                            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
                            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                            try await center.add(request)
                    }
                    
                }
            } catch {
                print(error)
            }
        }
    }
