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

@Model class Category {
    var name: String?
    init(name: String? = nil) {
        self.name = name
    }
}
@Model public class AdditionalReminderInformation {
    var category: Category?
    var isAlreadyCounter: Bool
    init(category: Category? = nil) {
        self.category = category
        self.isAlreadyCounter = false
    }
}

extension Event where Self: EKReminder {
    var extra: AdditionalReminderInformation;
}

class EventsService {
    // really bad events service
    // note: this does not implement caching, or anything nice in particular.
    
    var store: EKEventStore? = nil;
    var context: ModelContext? = nil;
    var container: ModelContainer? = nil;
    private let center = UNUserNotificationCenter.current()

    static let shared: EventsService = {
        let instance = EventsService()
            instance.initialize();
        // setup code
        return instance
    }()
    func createNewCategory(name: String) async {
        await container?.mainContext.insert(Category(name: "Jose"))
        do {
            try await container?.mainContext.save()
//            try await container?.mainContext.fetch(.)
        } catch {
            print(error)
        }

        
    }
    func getCategories() -> [Category] {
        print("Get categories")
        do {
            Task {
                let data = try await container?.mainContext.fetch(FetchDescriptor<Category>())
                print("DATA", data)
                return data
            }
        } catch {
            print("An error has occured", error)
        }
        return []
    }
    func getReminderById(_ identifier: String) -> EKReminder {
        return store?.calendarItem(withIdentifier: identifier) as! EKReminder
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
    func getRemindersPassed() async -> [EKReminder]? {
        var reminders = await getAllReminders();
        reminders = reminders?.filter({
            data in
//            data.creationDate
            return true
        })
        return reminders
    }
    func getAmountOwed() async -> Int {
        let reminders = await getAllReminders();
        
        let amountOwed = reminders?.reduce(0, {x, _ in x + 20});
        
        return amountOwed ?? 0
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
                print("notification or something, idk")
                let content = UNMutableNotificationContent()
                content.title = "aaaaaaa"
                content.body = "UwU oopsy woopsy"
                content.sound = .default
                
                let futureDate = Calendar.current.date(byAdding: .second, value: 10, to: Date())!
                
                let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: futureDate)
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5.0, repeats: false)
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

                center.add(request) { error in
                    if let error = error {
                        print("Error scheduling notification: \(error)")
                    } else {
                        print("Notification scheduled to fire in 1 minute")
                    }

                }

            }
        } catch {
            print(error)
        }
    }
}
