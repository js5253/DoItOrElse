//
//  ViewController.swift
//  DoItOrElse2
//
//  Created by jose on 2/20/24.
//

import UIKit
import EventKit
import SwiftUI

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var reminders: [EKReminder] = [];
    var store: EKEventStore = EKEventStore();
    var selected: String?;
    
    //    private var coreDataStack = CoreDataStack.shared;
    
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var todoTable: UITableView!
    @IBOutlet weak var demoButton: UIButton!
    @IBOutlet weak var tasksTableView: UITableView!;
    @IBAction func onTouchDown(_ sender: UITextField) {
        let hostingController = UIHostingController(rootView: NewTodoView(store: store))
        hostingController.modalPresentationStyle = .pageSheet
        // Present the hosting controller as a sheet
        present(hostingController, animated: true, completion: nil)
        
    }
    
    @IBAction func onDemoButtonPress(_ sender: Any) {
        let storyboard = UIStoryboard(name: "SomeView", bundle: nil) // Use your actual storyboard name
        if let viewController = storyboard.instantiateViewController(withIdentifier: "SomeView") as? SheetViewController {
            
            if let sheet = viewController.sheetPresentationController {
                sheet.detents = [
                    .custom {
                        _ in
                        return 400
                    }]
                viewController.modalPresentationStyle = .formSheet
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
        print("hello world")
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        if (tasksTableView != nil) {
            tasksTableView.dataSource = self;
            tasksTableView.delegate = self;
        }
                
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let theDestination = (segue.destination as! ReminderDetailsView)
//        theDestination.selectedId = selected
        

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
        let hostingController = UIHostingController(rootView: ReminderDetailsView(reminderId: id));
        hostingController.modalPresentationStyle = .pageSheet
        // Present the hosting controller as a sheet
        present(hostingController, animated: true, completion: nil)

    }

}
