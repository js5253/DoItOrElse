//
//  SettingsViewController.swift
//  DoItOrElse2
//
//  Created by jose on 3/13/24.
//

import Foundation
import UIKit
import SwiftUI
import EventKit

class SettingsViewController: ViewController {
    @IBOutlet weak var moneySpentHeadingLabel: UILabel!
    @IBOutlet weak var missedTasksLabel: UILabel!
    @IBOutlet weak var punishmentButton: UIButton!
    @IBOutlet weak var missedTaskTableView: UITableView!
    private var overdueReminders: [EKReminder] = [];
    
    
    @IBAction func chooseButton(_ sender: Any) {
        let hostingController = UIHostingController(rootView: ChoosePage())
        hostingController.modalPresentationStyle = .pageSheet

        hostingController.view.sizeToFit()
        // Present the hosting controller as a sheet
        present(hostingController, animated: true, completion: nil)

    }
    @IBOutlet weak var tasksDueTodayLabel: UILabel!
    
    @IBAction func onPayNowPressed(_ sender: Any) {
        print("Pay now pressed!")
        let storyboard = UIStoryboard(name: "PunishmentViewController", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "PunishmentViewController")
        self.present(vc, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad();
        missedTaskTableView.delegate = self;
        missedTaskTableView.dataSource = self;
        Task {
            overdueReminders = await EventsService.shared.getOverdueUnfinishedReminders()
            moneySpentHeadingLabel.text = await "$" + String( EventsService.shared.getAmountOwed())
            tasksDueTodayLabel.text = String(EventsService.shared.getReminderCount());
            
            if (overdueReminders.count > 0) {
                punishmentButton.isHidden = false;
                missedTasksLabel.text = "Missed Tasks"
                missedTasksLabel.textColor = .red
            }
        }
    }
}

extension SettingsViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("ASAASSA")
        return reminders.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        let id = reminders[indexPath.row].calendarItemIdentifier;
        //        let hostingController = UIHostingController(rootView: ReminderDetailsView(reminderId: id));
        //        hostingController.modalPresentationStyle = .pageSheet
        //        // Present the hosting controller as a sheet
        //        present(hostingController, animated: true, completion: nil)
        //
        //    }
        
    }
}
