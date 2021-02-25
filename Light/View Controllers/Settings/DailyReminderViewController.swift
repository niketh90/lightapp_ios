//
//  DailyReminderViewController.swift
//  Light
//
//  Created by apple on 09/04/20.
//  Copyright © 2020 Seraphic. All rights reserved.
//

import UIKit
import UserNotifications

class DailyReminderViewController: UIViewController {

    @IBOutlet var reminderSwitch:UISwitch?
    @IBOutlet var timeTextField:UITextField!
    @IBOutlet var contentStackView:UIStackView?
    var datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.datePickerMode = .time
        let profileDetail = getUserDetails()

        if let reminder = profileDetail?.dailyReminder, reminder.count > 0 {
            reminderSwitch?.isOn = true
            contentStackView?.isHidden = false
            timeTextField?.text = reminder
            reminderSwitch?.isOn = true
        }
        
        timeTextField?.inputView = datePicker
        timeTextField?.addDoneOnKeyboardWithTarget(self, action:  #selector(dateDoneAction))

        if #available(iOS 12.0, *) {
                 self.navigationController?.navigationBar.barTintColor = UIColor.bgColor
             }
        // Do any additional setup after loading the view.
    }
    
    @objc func dateDoneAction() {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "HH:mm"
        timeTextField?.text = dateFormater.string(from: datePicker.date)
        timeTextField?.resignFirstResponder()
       // setupNotification()
    }
    
    //MARK: userdefined function
    
    func setupNotification() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                self.scheduleNotification()

            } else {
                UNUserNotificationCenter.current().requestAuthorization(options: options) {
                   (granted, error) in
                   if granted {
                        self.scheduleNotification()
                   } else {
                       print("No")
                   }
               }
            }
        }
    }
    
    func scheduleNotification() {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        if let name = getUserDetails()?.firstName {
            content.title = "Hey \(name)!"
        } else {
            content.title = "Hey!"
        }
        
        content.body = "Your daily healing session is ready!"

        DispatchQueue.main.async {
            
            
            if let value = self.timeTextField?.text?.components(separatedBy: ":"), value.count == 2 {
                    let hour = Int(value[0])
                    let minute = Int(value[1])
                   
                    var dateComponents = DateComponents()
                    dateComponents.hour = hour
                    dateComponents.minute = minute
                     let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                  
                    let identifier = "Daily_session_Reminder"
                    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

                    center.add(request, withCompletionHandler: { (error) in
                        
                        
                        if let error = error {
                            
                            print(error.localizedDescription)
                            
                            
                        }else {
                            
                            
                        }
                    })
                
            }
        }
    }
    
    //MARK:Action
    @IBAction func goBackAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func reminderSwitchAction(sender: UISwitch) {
        
        
        if sender.isOn {
            setupNotification()
        } else {
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            
            timeTextField.text = ""
        }
    }
    
    
    @IBAction func goHomeAction() {
        self.dismiss(animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    
    @IBAction func setReminderAction() {
        guard let text = timeTextField.text else {
            self.showlAlet(title: "Oops!", message: "Please add reminder time.")
            return
        }
        
        addReminderApi(withParams: ["dailyReminder":text])
    }

    
    //MARK: Webservice
    func addReminderApi(withParams params :[String: Any]) {
        
        scheduleNotification()
        ServiceHelper.shared.sendAsyncRequestWith(withParam: params, httpMethod: .patch, apiName: .updateFrofile, showHud: true) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    
                    
                    guard let jsonData = data else {return}
                    do {
                        let userDict =  try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
                        var processodDict = [String: Any]()
                        
                        if let firstName = userDict?["firstName"] as? String {
                            processodDict["firstName"] = firstName
                        }
                        
                        if let lasttName = userDict?["lastName"] as? String {
                            processodDict["lastName"] = lasttName
                        }
                        
                        if let email = userDict?["email"] as? String {
                            processodDict["email"] = email
                        }
                        
                        if let healingTime = userDict?["healingTime"] as? Int {
                            processodDict["healingTime"] = healingTime
                        }
                        
                        if let healingDays = userDict?["healingDays"] as? Int {
                            processodDict["healingDays"] = healingDays
                        }
                        
                        if let currentStreak = userDict?["currentStreak"] as? Int {
                            processodDict["currentStreak"] = currentStreak
                        }
                        
                        if let profileImage = userDict?["profileImage"] as? String {
                            processodDict["profileImage"] = profileImage
                        }
                        
                        if let dailyReminder = userDict?["dailyReminder"] as? String {
                            processodDict["dailyReminder"] = dailyReminder
                        }
                        
                        if let isPasswordSet = userDict?["isPasswordSet"] as? Bool {
                            processodDict["isPasswordSet"] = isPasswordSet
                        }
                        
                        processodDict["token"] = getUserDetails()?.token
                        let jsonData = try JSONSerialization.data(withJSONObject: processodDict)
                        let userData = try JSONDecoder().decode(UserModel.self, from: jsonData)
                        saveUserDetails(data: userData)
                    } catch let error{
                        print(error.localizedDescription)
                    }
                } else {
                    guard let jsonData = data else {return}
                    do {
                        
                        let userDict =  try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
                        DispatchQueue.main.async {
                            if let message = userDict?["message"] as? String {
                                self.showlAlet(title: "Error!", message: message)
                            }
                        }
                    }catch {}
                }
            }
        }
    }
    
    
}
