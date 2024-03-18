//
//  PomoViewController.swift
//  DoItOrElse2
//
//  Created by jose on 2/20/24.
//

import Foundation
import UIKit

let POMODORO_WORK_MINUTES: Int = 25;
let POMDOORO_REST_MINUTES: Int = 5;

class PomoViewController: UIViewController {
    @IBOutlet weak var timesUpLabel: UILabel!
    @IBOutlet weak var stopPomoButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!;
    
    @IBOutlet var pomoInfoView: UIView!
//    @IBOutlet weak var pomoTimeBox: UITextField!
    @IBOutlet weak var timePicker: UIDatePicker!
    var timeLeft = POMODORO_WORK_MINUTES * 60; //
    var timerOn = false;
    var timer: Timer? = nil;
    var uiTimer: Timer? = nil;
    var isPomoOn = true;
    override func viewDidLoad() {
        super.viewDidLoad();
        print("Pomo")
        var dateComponents = DateComponents()
        dateComponents.hour = 0 // or 12 for "12:25"
        dateComponents.minute = 25
        
        let defaultTime = Calendar.current.date(from: dateComponents)!;
        
        timePicker.date = defaultTime;
        
    }
    @IBAction func onStartTimerPressed(_ sender: Any) {
        if timerOn {
            timer!.invalidate();
            uiTimer!.invalidate();
            timerOn = false;
            startButton.setTitle("Start Pomo", for: .normal)
            pomoInfoView.isHidden = false;
        } else {
            startLoop();
        }
    }
    @IBAction func onTimePickerChanged(_ sender: UIDatePicker) {
        let hours = Calendar.current.component(.hour, from: sender.date);
        var minutes = Calendar.current.component(.minute, from: sender.date);
        
        minutes += (60 * hours);
        
        timeLeft = minutes * 60
    }
    @IBAction func onStopPomoPressed(_ sender: Any) {
        uiTimer?.invalidate()
        timer?.invalidate()
        timerOn = false
        
        timePicker.isHidden = false
        timeLabel.isHidden = true
        startButton.setTitle("Start Pomo", for: .normal)
        stopPomoButton.isHidden = true;
    }
    func startLoop() {
        print("Timer set for \(timeLeft) seconds")
        startButton!.setTitle("Pause Pomo", for: .normal)
        timesUpLabel.isHidden = true;
        timerOn = true;
        timePicker.isHidden = true
        timeLabel.isHidden = false
        stopPomoButton.isHidden = false
        self.timeLabel.text = Utils.formatSecondsIntoString(self.timeLeft);
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(timeLeft), repeats: false, block: { [self]_ in
            startButton.setTitle("Start Pomo", for: .normal);
            timerOn = false;
            timesUpLabel.isHidden = false;
            print("Timer Started...")
            pomoInfoView.isHidden = false;
        })
        ///we likely need a UI timer too to advance every second
        uiTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(1), repeats: true, block: {[self]_ in
            print("Tick Started")
            DispatchQueue.main.async {
                self.timeLeft -= 1;
                self.timeLabel.text = Utils.formatSecondsIntoString(self.timeLeft);
            }
            if (self.timeLeft <= 1) {
                timePicker.isHidden = false;
                timeLabel.isHidden = true;
                // sound alarm
                timerOn = false;
                stopPomoButton.isHidden = true
                uiTimer?.invalidate();
                timer?.invalidate();
                startButton.setTitle("Start Pomo", for: .normal)
            }
        })
        let notification = UNMutableNotificationContent()
        notification.title = "Work Over!"
        notification.body = "Time to take a break or something"
        notification.sound = .default;
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(timeLeft), repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: notification, trigger: trigger)
        print("Notification scheduled for", trigger)
//        loop.add(timer!, forMode: .common);
//        loop.add(uiTimer!, forMode: .common);
    }
}
