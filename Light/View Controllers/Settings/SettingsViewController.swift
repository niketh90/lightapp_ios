//
//  SettingsViewController.swift
//  Light
//
//  Created by apple on 08/04/20.
//  Copyright © 2020 Seraphic. All rights reserved.
//

import UIKit
import MessageUI

class SettingsViewController: UIViewController {
    @IBOutlet var userNameLabel:UILabel!
    @IBOutlet var profileImageButton:UIButton!
    
    @IBOutlet weak var version_lbl: UILabel!
    
    struct settingsModal{
        var icon: UIImage!
        var text: String!
    }
    
    let dataSource : [settingsModal] = [
        settingsModal(icon: #imageLiteral(resourceName: "icn_user_green"), text: "User Statistics"),
        settingsModal(icon: #imageLiteral(resourceName: "icn_reminder_cyan"), text: "Daily Reminder"),
        settingsModal(icon: #imageLiteral(resourceName: "icn_help_cyan"), text: "Help & Support"),
        settingsModal(icon: #imageLiteral(resourceName: "icn_about_cyan"), text: "About"),
        settingsModal(icon: #imageLiteral(resourceName: "icn_logout_cyan"), text: "Log Out")
    ]
    
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let profileDetail = getUserDetails()
        userNameLabel.text = "\(profileDetail?.firstName ?? "") \(profileDetail?.lastName ?? "")"
         profileImageButton?.sd_setBackgroundImage(with: URL(string: profileDetail?.profileImage ?? ""), for: .normal, completed: { (image, error, SDImageCacheType, url) in
            if image != nil {
                self.profileImageButton.setImage(image, for: .normal)
            }
         })
        
        version_lbl.text = "Version \(appVersion ?? "")"
    }
    //MARK: Userdefined function
    func logoutConfirmation() {
        let alertController = UIAlertController(title: nil, message: "Are you sure you want to logout?", preferredStyle: .alert)

        let yesAction = UIAlertAction.init(title: "Yes", style: .default) { (action) in
            self.logoutApi()
        }
        
        let noAction = UIAlertAction.init(title: "No", style: .default) { (action) in
            
        }
        
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func closeBttnAction() {
        NotificationCenter.default.post(name: Notification.Name("Setting Shut Down"), object: nil, userInfo: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editProfileBttnAction() {
        let vc : EditProfileViewController = EditProfileViewController.instantiate()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: Webservice
    func logoutApi(){
        let userDict = getUserDetails()
        let params = ["deviceType" : "1",
                      "deviceToken": userDict?.token ?? ""]
        ServiceHelper.shared.sendAsyncRequestWith(withParam: params, httpMethod: .post, apiName: .logout, showHud: true) { (date, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    let vc =  ViewController.instantiate()
                    let nvc = UINavigationController.init(rootViewController: vc)
                  //  nvc.navigationBar.isHidden = true
                     nvc.navigationBar.barTintColor = UIColor.clear
                    if #available(iOS 12.0, *) {
                             self.navigationController?.navigationBar.barTintColor = UIColor.bgColor
                         }
                    appDelegate().setRootViewController(vc: nvc)
                    emptyUserDetails()
                    UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                }
            }

        }
    }
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
   return section == 0 ? 4 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell") as! SettingsTableViewCell
       
        cell.logoImage.image = indexPath.section == 0 ? dataSource[indexPath.row].icon : dataSource.last?.icon
        cell.titleText.text = indexPath.section == 0 ? dataSource[indexPath.row].text : dataSource.last?.text
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
           
            case 0:
                switch indexPath.row {
                   case 0:
                       let vc = UserStatisticsViewController.instantiate()
                       self.navigationController?.pushViewController(vc, animated: true)
                   case 1:
                       let vc = DailyReminderViewController.instantiate()
                       self.navigationController?.pushViewController(vc, animated: true)
                   case 2:
                        if MFMailComposeViewController.canSendMail() {
                              let mail = MFMailComposeViewController()
                              mail.mailComposeDelegate = self
                              mail.setToRecipients(["info@lightforcancer.com"])
                              present(mail, animated: true)
                          } else {
                           self.showlAlet(title: "Error!", message: "Your e-mail is not configured in your phone.\n Please configure your e-mail first.")
                          }
                   case 3:
                       let vc = AboutViewController.instantiate()
                       self.navigationController?.pushViewController(vc, animated: true)
                case 4:
                    let vc = InAppViewController.instantiate()
                    self.navigationController?.pushViewController(vc, animated: true)
                   default:
                       print("")
                   }
            case 1:
                
                
                DispatchQueue.main.async {
                    self.logoutConfirmation()
                }
        default:
            break
        }
        
   
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 80))
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        guard section == 1 else { return nil }
//        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 200))
//        let label = UILabel(frame: CGRect(x: (tableView.frame.width / 2) - 100, y: 150, width: 200, height: 50))
//        label.font = UIFont.setFont(type: .f500Rounded, of: 14)
//        label.textColor = .darkGray
//        label.text = "Version \(appVersion ?? "")"
//        label.textAlignment = .center
//        view.addSubview(label)
//        return view
//    }
//
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        guard section == 1 else { return .zero }
//        return 200
//    }
}

extension SettingsViewController : MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if error == nil {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
}


