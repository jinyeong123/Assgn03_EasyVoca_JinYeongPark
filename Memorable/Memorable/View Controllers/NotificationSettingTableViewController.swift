//
//  NotificationSettingTableViewController.swift
//  Memorable
//
//
//  Created by Paige 🇰🇷 on 12/5/2023.
//

import UIKit
import UserNotifications
import os.log

class NotificationSettingTableViewController: UITableViewController, UNUserNotificationCenterDelegate {

    
    var memorable = Memorable(id: -1, head: "", body: "", category: "")
    var turnOnOffValue = false
    var notificationSettings: [NotificationSetting] = []
    

    
    @IBOutlet weak var repeatLabel: UILabel!
    @IBOutlet weak var repeatIntervalSlider: UISlider!
    @IBOutlet weak var turnOnOffSwitch: UISwitch!
    

    
    @IBAction func repeatIntervalSliderValueChanged(_ sender: Any) {
        self.repeatLabel.text = String(Int(self.repeatIntervalSlider.value)) + " seconds"
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        let notificationSetting = NotificationSetting(memorable: self.memorable, repeatInterval: Int(self.repeatIntervalSlider.value), turnOnOff: self.turnOnOffValue)
        self.notificationSettings.append(notificationSetting)
        self.saveNotificationSettings()
        if self.turnOnOffValue {
            self.requestLocalNotification(timeInterval: Int(self.repeatIntervalSlider.value))
            self.alertWithSegue(title: self.memorable.head, message: "Notification on", dismissButtonText: "Go back", segueIdentifier: "UnwindFromNotificationSettingTableViewController")
        } else {
            self.removeNotifications()
            self.alertWithSegue(title: self.memorable.head, message: "Notification off", dismissButtonText: "Go back", segueIdentifier: "UnwindFromNotificationSettingTableViewController")
        }
    }
    
    @IBAction func turnOnOffSwitchValueChanged(_ sender: Any) {
        if self.turnOnOffValue {
            self.turnOnOffValue = false
        } else {
            self.turnOnOffValue = true
        }
    }

    
    func requestLocalNotification(timeInterval: Int) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            
            print("Permission granted: \(granted)")
            guard granted else { return }
            
            UNUserNotificationCenter.current().getNotificationSettings {
                (settings) in
                
                print("Notification settings: \(settings)")
                print("Authorization Status: \(settings.authorizationStatus.rawValue)")
                guard settings.authorizationStatus == .authorized else {
                    print("Not authorized")
                    return
                }
                

                let content = UNMutableNotificationContent()
                

                content.title = self.memorable.head

                content.body = self.memorable.body
                content.badge = 0
                
                

                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(timeInterval), repeats: true)
                

                let request = UNNotificationRequest(identifier: String(self.memorable.id), content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().delegate = self
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            }
        }
    }
    
    func removeNotifications() {

        var identifier: [String] = []
        identifier.append(String(self.memorable.id))
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifier)
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: identifier)
    }
    
    func alertWithSegue(title: String, message: String, dismissButtonText: String, segueIdentifier: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let dismissAction = UIAlertAction(title: dismissButtonText,style: UIAlertActionStyle.default) {
            (action) -> Void in
            self.performSegue(withIdentifier: segueIdentifier, sender: self)
        }
        alertController.addAction(dismissAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func saveNotificationSettings() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(notificationSettings, toFile: NotificationSetting.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("NotificationSetting successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save NotificationSetting...", log: OSLog.default, type: .error)
        }
    }
    
    func loadNotificationSettings() {
        if let savedNotificationSettings = NSKeyedUnarchiver.unarchiveObject(withFile: NotificationSetting.ArchiveURL.path) as? [NotificationSetting] {
            self.notificationSettings = savedNotificationSettings
        } else {
            os_log("Failed to laod NotificationSetting...", log: OSLog.default, type: .error)
        }
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = self.memorable.head
        self.loadNotificationSettings()
        for notificationSetting in self.notificationSettings {
            let memorable = notificationSetting.memorable
            let repeatInterval = notificationSetting.repeatInterval
            let turnOnOff = notificationSetting.turnOnOff
            if self.memorable.id == memorable.id {
                self.repeatIntervalSlider.setValue(Float(repeatInterval), animated: false)
                self.repeatLabel.text = String(Int(self.repeatIntervalSlider.value)) + " seconds"
                self.turnOnOffSwitch.setOn(turnOnOff, animated: false)
                self.turnOnOffValue = turnOnOff
            }
        }
    }

}
