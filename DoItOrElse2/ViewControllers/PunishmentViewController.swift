//
//  PunishmentViewController.swift
//  DoItOrElse2
//
//  Created by jose on 3/17/24.
//

import Foundation
import UIKit
import WebKit
class PunishmentViewController : ViewController {
    
    
    @IBOutlet weak var punishmentWebView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let myURL = URL(string:"https://www.apple.com")
        let myRequest = URLRequest(url: myURL!)
        punishmentWebView.load(myRequest)
    }
    @IBAction func onDonePressed(_ sender: Any) {
//        AppSettings.shared.resetOwed()
    }
    
}
