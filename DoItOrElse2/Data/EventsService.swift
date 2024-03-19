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
        func setAllRemindersComplete() async {
            let rem = await getAllReminders()!;
            do {
                try rem.forEach({reminder in
                    reminder.priority = 1;
                    try store!.save(reminder, commit: true)
                })

            }
            catch {
                print(error)
            }
        }
        func markComplete(_ reminder: EKReminder) {
            reminder.isCompleted = true
            do {
                try store!.save(reminder, commit: true)
                
            } catch {
                print(error)
            }
        }
        func removeReminder(_ reminder: EKReminder) {
            do {
                try store?.remove(reminder, commit: true)

            } catch {
                print(error)
            }
        }
        func getCurrentReminder() {
//            getFutureReminders(predicate: #Predicate({ reminder in
//                
//            }))
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
        func getCategoriesSync() -> [Category] {
            Task {
                do {
                    let data = try await container?.mainContext.fetch(FetchDescriptor<Category>())
                    return data;

                }
                catch {
                    return []
                }
            }
            return []
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
                var config = ModelConfiguration(isStoredInMemoryOnly: false)
                container = try ModelContainer(for: Category.self, configurations: config);
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
            func getOverdueUnfinishedReminders() async -> [EKReminder] {
                print("Get overdue unfinished reminders")
                let oneDayAgo = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
                print(oneDayAgo)
                
                // really bad way to create predicate from a day ago
                let reminders = await getAllReminders() ?? [];
                
                return reminders.filter({
                    reminder in
                    
                    return reminder.creationDate!.compare(oneDayAgo) == .orderedAscending && reminder.priority != 9
                })
                
            }
        func getIncompleteReminders() async -> [EKReminder]? {
                let allReminders = await getAllReminders()
            
            return allReminders?.filter({reminder in
                return !reminder.isCompleted
                
            })
            }
        
        func getAllReminders() async -> [EKReminder]? {
                print("Get All events...")
                
                let predForAllItems = self.store!.predicateForIncompleteReminders(withDueDateStarting: nil, ending: nil, calendars: [self.store!.defaultCalendarForNewReminders()!]);
                return await getRemindersWithPredicate(predicate: predForAllItems)

            }
        
        func getAmountOwed() async -> Int {
                let reminders = await getOverdueUnfinishedReminders();
                
            let amountOwed = reminders.reduce(0,
                                              {x, reminder in
                return x + (Utils.daysSinceCreation(reminder)! * 20)
            })
                return amountOwed
            }
        func getReminderById(_ identifier: String) -> EKReminder {
            return store?.calendarItem(withIdentifier: identifier) as! EKReminder
        }
        func createReminder(todoName: String, todoDueDate: Date?, hasNotification: Bool) {
            let ev = EKReminder(eventStore: store!)
            ev.title = todoName;
            ev.priority = 1;
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
                            content.body = "Do this before the end of the day!"
                        let fiveH = Utils.getDateFiveHoursBeforeEndOfToday()
                        if (fiveH != nil) {
                            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
                            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                            try await center.add(request)
                        } else {
                            print("idk")
                        }
                            
                    }
                    
                }
            } catch {
                print(error)
            }
        }
    }
