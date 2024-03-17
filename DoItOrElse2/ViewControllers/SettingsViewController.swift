//
//  SettingsViewController.swift
//  DoItOrElse2
//
//  Created by jose on 3/13/24.
//

import Foundation
import UIKit
import SwiftUI

class SettingsViewController: ViewController {
    @IBOutlet weak var moneySpentHeadingLabel: UILabel!
    @IBAction func chooseButton(_ sender: Any) {
        let hostingController = UIHostingController(rootView: ChoosePage())
        hostingController.modalPresentationStyle = .pageSheet

        hostingController.view.sizeToFit()
        // Present the hosting controller as a sheet
        present(hostingController, animated: true, completion: nil)

    }
    @IBOutlet weak var tasksDueTodayLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        Task {
            moneySpentHeadingLabel.text = await "$" + String( EventsService.shared.getAmountOwed())
            tasksDueTodayLabel.text = String(EventsService.shared.getReminderCount());
        }
    }
}
