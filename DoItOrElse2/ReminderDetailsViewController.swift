//
//  ReminderDetailsViewController.swift
//  DoItOrElse2
//
//  Created by jose on 3/13/24.
//

import Foundation
import UIKit

class ReminderDetailsViewController: UIViewController {
    var selectedId: String? = nil;
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    override func viewDidLoad() {
        print(selectedId)
        super.viewDidLoad()
    }

}
