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
            let rem = await EventsService.shared.getAllReminders()
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
    
    @IBAction func onDemoButtonPress(_ sender: Any) {
        let storyboard = UIStoryboard(name: "SomeView", bundle: nil) // Use your actual storyboard name
        if let viewController = storyboard.instantiateViewController(withIdentifier: "SomeView") as? SheetViewController {
            
            if let sheet = viewController.sheetPresentationController {
                viewController.modalPresentationStyle = .pageSheet
                present(viewController, animated: true, completion: nil)
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task {
            let rem = await EventsService.shared.getAllReminders()
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
        
        let hoursLeft = Utils.hoursLeftInDay()!;
        if (hoursLeft < 6) {
            hoursLeftLabel.textColor = .orange
        } else if (hoursLeft < 3) {
            hoursLeftLabel.textColor = .red
        }
        if (hoursLeftLabel != nil) {
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
            notifs.forEach({
                notif in
                if (!notif.content.title.contains("Time to Do it... or Else")) {
                    let content = UNMutableNotificationContent();
                    content.title = "Time to Do it... or Else"
                    content.body = "You have unfinished tasks, do them!"
                    content.sound = .defaultCritical
                    let interval = Utils.getDateFiveHoursBeforeEndOfToday()!.timeIntervalSinceNow
                    if (interval < 60) {return}
                    let dailyNot = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: true))
                    center.add(dailyNot)
                }
            })
//            if (center.getPendingNotificationRequests(completionHandler: {
//        }
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
            let alreadyPassed = (reminder.completionDate != nil) ? Utils.dateAlreadyPassed(reminder.completionDate!) : false;
            cell.todoTitle.text = reminder.title // Assuming your reminder has a 'title' property
            if (alreadyPassed) {
                cell.todoDescription.textColor = .red;
                cell.todoDescription.text! += "Overdue - "
            }
            let dateString = ""
            if ((reminder.dueDateComponents) != nil) {
//                cell.todoDescription.text! += String(reminder.dueDateComponents!.month);
                if (reminder.dueDateComponents!.month != nil) {
                    cell.todoDescription.text! += String(reminder.dueDateComponents!.month!)
                }
                cell.todoDescription.text! += "/"
                if (reminder.dueDateComponents!.day != nil) {
                    cell.todoDescription.text! += String(reminder.dueDateComponents!.day!)
                }
            }
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
