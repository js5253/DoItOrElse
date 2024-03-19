//
//  ViewController.swift
//  DoItOrElse2
//
//  Created by jose on 2/20/24.
//

import UIKit
import EventKit
import SwiftUI

protocol DismissDelegate {
    func didDismissSwiftUIView()
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DismissDelegate {
    
    
    var reminders: [EKReminder] = [];
    var store: EKEventStore = EKEventStore();
    var selected: String?;
    
    //    private var coreDataStack = CoreDataStack.shared;
    
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var todoTable: UITableView!
    @IBOutlet weak var hoursLeftLabel: UILabel!
    @IBOutlet weak var demoButton: UIButton!
    @IBOutlet weak var tasksTableView: UITableView!;
    
    func didDismissSwiftUIView() {
            // Perform your desired function here
        Task {
            let rem = await EventsService.shared.getIncompleteReminders()
            await MainActor.run {
                self.reminders = rem ?? []
                if (tasksTableView != nil) {
                     // BUG
                    self.tasksTableView.reloadData() // Reload the table view on the main thread
                }
            }
        }
        }

    @IBAction func onTouchDown(_ sender: UITextField) {
        var newTodoView = NewTodoView()
        newTodoView.dismissDelegate = self
        let hostingController = UIHostingController(rootView: newTodoView)
        hostingController.modalPresentationStyle = .pageSheet

        hostingController.view.sizeToFit()
        // Present the hosting controller as a sheet
        present(hostingController, animated: true, completion: nil)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task {
            let rem = await EventsService.shared.getIncompleteReminders()
            await MainActor.run {
                self.reminders = rem ?? []
                if (tasksTableView != nil) {
                     // BUG
                    self.tasksTableView.reloadData() // Reload the table view on the main thread
                }
            }
        }

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        
        
        if (hoursLeftLabel != nil) {
            let hoursLeft = Utils.hoursLeftInDay()!;
            if (hoursLeft < 6) {
                hoursLeftLabel.textColor = .orange
            } else if (hoursLeft < 3) {
                hoursLeftLabel.textColor = .red
            }
            hoursLeftLabel.text = "\(hoursLeft) hours left"
        }
        
        if (headerLabel != nil) {
            headerLabel.text = Utils.getRandomHeading()
        }
        if (tasksTableView != nil) {
            tasksTableView.dataSource = self;
            tasksTableView.delegate = self;
        }
        let center = EventsService.shared.center;
        Task {
            let notifs = await center.pendingNotificationRequests();
            print(notifs)
            
            let a = notifs.filter({
                notification in
                return notification.content.title == "Time to Do it... or Else"
            })
            
            let content = UNMutableNotificationContent();
            content.title = "Time to Do it... or Else"
            content.body = "You have unfinished tasks, do them!"
            content.sound = .defaultCritical
            let interval = Utils.getDateFiveHoursBeforeEndOfToday()!.timeIntervalSinceNow
            if (interval < 60) {return} /// getDateFiveHoursBeforeToday is kinda bugged
            let dailyNot = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: true))
            try await center.add(dailyNot)

            
            let weeklyNotification = UNMutableNotificationContent();
            weeklyNotification.title = "A new week awaits"
            weeklyNotification.body = "You might've missed a few tasks and need to donate $20"
            weeklyNotification.sound = .default
            let interval2 = Utils.getTimeIntervalToEndOfWeek()
            if (interval2 != nil) {
                let weeklyNotReq = UNNotificationRequest(identifier: UUID().uuidString, content: weeklyNotification, trigger: UNTimeIntervalNotificationTrigger(timeInterval: interval2!, repeats: true))
                do {
                    try await center.add(weeklyNotReq)
                } catch {
                    print("error scheduling weekly notif")
                }

            }


    }
}
}
// MARK: TableView data functions

extension ViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return reminders.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as? MyTableViewCell else {
                fatalError("Unable to dequeue CustomTableViewCell")
            }
            cell.todoDescription.text = ""
            let reminder = reminders[indexPath.row]
            let alreadyPassed = (Utils.dateAlreadyPassed(reminder.creationDate!)) ? Utils.dateAlreadyPassed(reminder.creationDate!) : false;
            cell.todoTitle.text = reminder.title // Assuming your reminder has a 'title' property
            if (alreadyPassed) {
                cell.todoDescription.textColor = .red;
                cell.todoDescription.text! += "Overdue - "
            }
            cell.todoDescription.text! += reminder.creationDate!.formatted(date: .abbreviated, time: .omitted)
            return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let id = reminders[indexPath.row].calendarItemIdentifier;
        var reminderDetailsView = ReminderDetailsView(reminderId: id);
        reminderDetailsView.dismissDelegate = self

        let hostingController = UIHostingController(rootView: reminderDetailsView);
        hostingController.modalPresentationStyle = .pageSheet
        // Present the hosting controller as a sheet
        present(hostingController, animated: true, completion: nil)

    }

}
