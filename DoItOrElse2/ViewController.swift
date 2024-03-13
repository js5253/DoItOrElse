//
//  ViewController.swift
//  DoItOrElse2
//
//  Created by jose on 2/20/24.
//

import UIKit
import EventKit
import SwiftUI

class ViewController: UIViewController {
    var reminders: Optional<[EKReminder]> = .none;
    var store: EKEventStore = EKEventStore();
    
//    private var coreDataStack = CoreDataStack.shared;
    
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var todoCollection: UICollectionView!
    @IBOutlet weak var demoButton: UIButton!

    func displayToDoItems() {
        switch(reminders) {
        case .none: print("None")
        case .some(let rem): do {
            print("ASAASSA")
        }
        }
    }
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
        
    }
    override func viewDidLoad() {
        print("hello world")
        super.viewDidLoad()
        
        EventsService.shared.getReminders(completion: {
            reminders in
            print(reminders)
        })
                
    }
    }


extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected item")
    }
}
extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12;
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "", for: indexPath)
        
        return cell
    }
}

//extension ViewController: UICollectionViewDelegateFlowLayout {
//    
//}

