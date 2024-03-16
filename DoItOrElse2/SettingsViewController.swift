//
//  SettingsViewController.swift
//  DoItOrElse2
//
//  Created by jose on 3/13/24.
//

import Foundation
import UIKit

class SettingsViewController: ViewController {
    @IBOutlet weak var moneySpentHeadingLabel: UILabel!
    
    @IBOutlet weak var tasksDueTodayLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        Task {
            moneySpentHeadingLabel.text = await "$" + String( EventsService.shared.getAmountOwed())
            tasksDueTodayLabel.text = String(EventsService.shared.getReminderCount());
        }
    }
}
