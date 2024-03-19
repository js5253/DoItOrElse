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
    @IBOutlet weak var totalTasksLabel: UILabel!
    @IBOutlet weak var moneySpentHeadingLabel: UILabel!
    @IBOutlet weak var missedTasksLabel: UILabel!
    @IBOutlet weak var punishmentButton: UIButton!
    @IBOutlet weak var tasksTodayLabel: UILabel!
    @IBOutlet weak var missedTaskTableView: UITableView!
    private var overdueReminders: [EKReminder] = [];
    @IBOutlet weak var hoursLeftBadge: UIButton!
    
    
    @IBAction func chooseButton(_ sender: Any) {
        let hostingController = UIHostingController(rootView: ChoosePage())
        hostingController.modalPresentationStyle = .pageSheet

        hostingController.view.sizeToFit()
        // Present the hosting controller as a sheet
        present(hostingController, animated: true, completion: nil)

    }
    @IBOutlet weak var tasksDueTodayLabel: UILabel!
    
    @IBAction func onPayNowPressed(_ sender: Any) {
        let hostingController = UIHostingController(rootView: PunishmentView())
        hostingController.modalPresentationStyle = .pageSheet

        hostingController.view.sizeToFit()
        // Present the hosting controller as a sheet
        present(hostingController, animated: true, completion: nil)


    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        Task {
            totalTasksLabel.text = await String( EventsService.shared.getAllReminders()!.count)
            hoursLeftBadge.setTitle(String(Utils.hoursLeftInDay()!) + "H LEFT", for: .disabled)
            overdueReminders = await EventsService.shared.getOverdueUnfinishedReminders()
            moneySpentHeadingLabel.text = await "$" + String( EventsService.shared.getAmountOwed())
            tasksDueTodayLabel.text = await String(EventsService.shared.getIncompleteReminders()!.count);
            
            if (overdueReminders.count > 0) {
                punishmentButton.isHidden = false;
                missedTasksLabel.text = "\(overdueReminders.count) Missed Tasks"
                missedTasksLabel.textColor = .red
            }
            self.missedTaskTableView.reloadData()
        }

    }
    override func viewDidLoad() {
        super.viewDidLoad();
        missedTaskTableView.delegate = self;
        missedTaskTableView.dataSource = self;
    }
}

extension SettingsViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("ASAASSA")
        return overdueReminders.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as? MyTableViewCell else {
            fatalError("Unable to dequeue CustomTableViewCell")
        }
        cell.todoDescription.text = ""
        let reminder = overdueReminders[indexPath.row]
        let alreadyPassed = (reminder.completionDate != nil) ? Utils.dateAlreadyPassed(reminder.completionDate!) : false;
        cell.todoTitle.text = reminder.title // Assuming your reminder has a 'title' property
        if (alreadyPassed) {
            cell.todoDescription.textColor = .red;
            cell.todoDescription.text! += String(Utils.daysSinceCreation(reminder)!) + "d"
        }
        if ((reminder.dueDateComponents) != nil) {
//                cell.todoDescription.text! += String(reminder.dueDateComponents!.month);
            if (reminder.dueDateComponents!.month != nil) {
                cell.todoDescription.text! += " " + String(reminder.creationDate!.formatted(date: .abbreviated, time: .omitted))
            }
        }
        return cell
}
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "SomeView") as! BegViewController
        viewController.reminder = overdueReminders[indexPath.row]
        viewController.dismissDelegate = self;
        present(viewController, animated: true, completion: nil)
    }
}

