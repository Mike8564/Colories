//
//  InterfaceController.swift
//  Colories WatchKit Extension
//
//  Created by Mike Sedaghatnia on 2021-02-20.
//

import WatchKit
import Foundation
import UserNotifications

class InterfaceController: WKInterfaceController {
    @IBOutlet weak var TLButton: WKInterfaceButton!
    @IBOutlet weak var TRButton: WKInterfaceButton!
    @IBOutlet weak var BLButton: WKInterfaceButton!
    @IBOutlet weak var BRButton: WKInterfaceButton!
    
    var buttons = [WKInterfaceButton]()
    let colors = ["red":UIColor.red, "geen":UIColor.green, "blue":UIColor.blue, "orange":UIColor.orange, "purple":UIColor.purple, "black":UIColor.black]
    var startTimer = Date()
    var currentLevel = 0
    
    override func awake(withContext context: Any?) {
        buttons = [TLButton, TRButton, BRButton, BLButton]
        setPlayReminder()
        startGame()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }
    ///////////
    
    @IBAction func startGame() {
        startTimer = Date()
        currentLevel = 0
        levelUp()
    }
    
    func levelUp() {
        currentLevel += 1
        
        if currentLevel == 2 {
            let playAgain = WKAlertAction(title: "Play again!", style: .default) {
                self.startGame()
            }
            
            let timePassed = Date().timeIntervalSince(startTimer)
            
            presentAlert(withTitle: "You Won!", message: "You finished the game in \(Int(timePassed)) seconds", preferredStyle: .alert, actions: [playAgain])
        }
        
        var colorKeys = Array(colors.keys)
        colorKeys.shuffle()
        buttons.shuffle()
        
        // loop over all buttons
        for (index, button) in buttons.enumerated() {
            
            // give them a color from dictionary
            button.setBackgroundColor(colors[colorKeys[index]])
            
            button.setEnabled(true)
            
            if index == 0 {
                // button should have wrong title
                
                button.setTitle(colorKeys[colorKeys.count - 1])
            } else {
                // button should have correct title
                button.setTitle(colorKeys[index])
            }
        }
    }

    func buttonTapped(_ button:WKInterfaceButton) {
        if button == buttons[0] {
            // correct button
            levelUp()
        } else {
            // wrong - make try again
            button.setEnabled(false)
        }
    }
    
    func createNotification() {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "We miss you!"
        content.body = "Come and play again!"
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "Play_Reminder"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
         
    }
    
    func setPlayReminder() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert,.sound]) { (success, error) in
            if success {
                self.registerCategories()
                center.removeAllPendingNotificationRequests()
                self.createNotification()
            }
        }
    }
    
    func registerCategories() {
        let center = UNUserNotificationCenter.current()
        let play = UNNotificationAction(identifier: "Play", title: "Play Now", options: .foreground)
        let category = UNNotificationCategory(identifier: "Play_Reminder", actions: [play], intentIdentifiers: [])
        
        center.setNotificationCategories([category])
    }

    @IBAction func TLButtonTapped() {
        buttonTapped(TLButton)
    }
    @IBAction func TRButtonTapped() {
        buttonTapped(TRButton)
    }
    @IBAction func BRButtonTapped() {
        buttonTapped(BRButton)
    }
    @IBAction func BLButtonTapped() {
        buttonTapped(BLButton)
    }
}
