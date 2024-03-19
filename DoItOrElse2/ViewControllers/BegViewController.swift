//
//  BegViewController.swift
//  DoItOrElse2
//
//  Created by jose on 3/4/24.
//

import Foundation
import UIKit
import EventKit
class BegViewController: UIViewController {
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    public var reminder: EKReminder!
    @IBOutlet weak var daysAgo: UILabel!
    var dismissDelegate: DismissDelegate?
    @IBOutlet weak var begTextField: UITextView!
    @IBOutlet weak var begTextResult: UITextView!
    let api_key = ProcessInfo.processInfo.environment["OPENAI_KEY"]!
    let prompt = """
You are Edgeworth, an attorney that decides whether someone is punished or not. You are part of a system that strongly encourages people to do to their goals. The app will punish people by removing $20 from their accounts for any missed to-do item. The app will include their task, and the user will explain their task. Be strict and legal-sounding (like the Ace Attorney Character), but do allow for leeway in some circumstances. The application uses JSON to communicate, so the two responses acceptable are:

{"pardoned": true, "description": "explanation here..."} or {"pardoned": false, "description": "explanation here..."}

"""
    override func viewDidLoad() {
        taskLabel.text = "Task: " + reminder.title
        daysAgo.text = String( Utils.daysSinceCreation(reminder!)!)
    }
    @IBAction func onBackPress(_ sender: Any) {
        self.dismissDelegate?.didDismissSwiftUIView()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onButtonPress(_ sender: Any) {
        print("onBegButtonPress")
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            print("Invalid URL")
            return
        }
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": prompt + "Task: \(reminder.title ?? "Uhhh, something's gone wrong. Mention the error in your response")"],
                ["role": "user", "content": begTextField.text!]
            ],
            "temperature": 0.7
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            print("Failed to serialize request body")
            return
        }
        var request = URLRequest(url: url)

        request.setValue("Bearer \(api_key)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) {
         data, response, httpErr in
            guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid HTTP response")
                    return
                }

                // Check status code
                if httpResponse.statusCode == 200 {
                    // Parse and handle response data
                    if let responseData = data {
                        let text = String(data: responseData, encoding: .utf8) ?? "No response data"
                        print(text)
                        do {
                            let response = try JSONDecoder().decode(ChatGPTResponse.self, from: responseData).choices[0].message.content
                            DispatchQueue.main.async {
                                if (response.pardoned) {
                                    EventsService.shared.removeReminder(self.reminder)
                                    let alert = UIAlertController(title: "Success!", message: "Pardoned, you don't have to pay $20 for that lol", preferredStyle: .alert)
                                    self.present(alert, animated: true)
                                    Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { timer in
                                                alert.dismiss(animated: true, completion: nil)
                                            }

                                } else {
                                    let alert = UIAlertController(title: "Ruh roh!", message: "Should've thought of a better excuse lol", preferredStyle: .alert)
                                    self.present(alert, animated: true)
                                    Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { timer in
                                                alert.dismiss(animated: true, completion: nil)
                                            }

                                }
                                self.backButton.isHidden = false
                                self.begTextResult.text = response.description;
                            }

                        } catch {
                            print(error, "error oof")
                        }
                    } else {
                        print("No response data")
                    }
                } else {
                    print("HTTP response error: \(httpResponse.statusCode)")
                }
        }
        task.resume()

    }
    
    
}
