//
//  PomoViewController.swift
//  DoItOrElse2
//
//  Created by jose on 2/20/24.
//

import Foundation
import UIKit

class PomoViewController: UIViewController {
    @IBOutlet weak var timesUpLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!;
    @IBOutlet var pomoInfoView: UIView!
    @IBOutlet weak var pomoInfoLabel: UILabel!
    var timeLeft = 0;
    var timerOn = false;
    var timer: Timer? = nil;
    var uiTimer: Timer? = nil;
    override func viewDidLoad() {
        super.viewDidLoad();
        print("Pomo")
        pomoInfoLabel.text = String(timeLeft)
        
    }
    @IBAction func onStartTimerPressed(_ sender: Any) {
        if timerOn {
            timer!.invalidate();
            timerOn = false;
            startButton.setTitle("Start Pomo", for: .normal)
            pomoInfoView.isHidden = false;
        } else {
            startLoop(1);
        }
    }
    func startLoop(_ minutes: Int) {
        timesUpLabel.isHidden = true;
        timeLeft = minutes * 60
        timerOn = true;
        startButton.setTitle("Stop Pomo", for: .normal)
        let loop = RunLoop.main;
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(timeLeft), repeats: false, block: { [self]_ in
            startButton.setTitle("Start Pomo", for: .normal);
            timerOn = false;
            timesUpLabel.isHidden = false;
            print("Hello world aaaaa")
            pomoInfoView.isHidden = false;
        })
        uiTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(1), repeats: true, block: {[self]_ in
            print("ASASASASAS")
            DispatchQueue.main.async {
                self.timeLeft -= 1;
                self.pomoInfoLabel.text = String(self.timeLeft);
            }
            if (self.timeLeft <= 1) {
                // sound alarm
                timerOn = false;
                uiTimer?.invalidate();
                timer?.invalidate();
                startButton.setTitle("Start Pomo", for: .normal)
            }
        })
//        loop.add(timer!, forMode: .common);
//        loop.add(uiTimer!, forMode: .common);
    }
}
