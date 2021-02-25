//
//  ReviewViewController.swift
//  Light
//
//  Created by apple on 09/04/20.
//  Copyright © 2020 Seraphic. All rights reserved.
//

import UIKit



class ReviewViewController: CustomNavBar {

    @IBOutlet var rateBUttonCollection: [UIButton]!
    @IBOutlet var autherImage: UIImageView!
    @IBOutlet var autherName: UILabel!
  
    @IBOutlet var ratingMessageLabel: UILabel!

     @IBOutlet var healingMinuteLabel: UILabel!
     @IBOutlet var healingDayLabel: UILabel!
     @IBOutlet var currentStreakLabel: UILabel!
    
    @IBOutlet var homeButton: UIButton!
    @IBOutlet var sharebutton: UIButton!
   
    var delegate : popToRootVCDelegate?
    var session:DailySessionModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        autherName.text = session?.sessionAuthor?.authorName
        ratingMessageLabel.text = session?.ratingMessage
        autherImage.sd_setImage(with: URL.init(string: (session?.sessionAuthor?.authorImage ?? "").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""), placeholderImage: UIImage.init(named: ""), options: .refreshCached, context: nil)
        // Do any additional setup after loading the view.
        
        if #available(iOS 12.0, *) {
                 self.navigationController?.navigationBar.barTintColor = UIColor.bgColor
             }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ServiceHelper.shared.sendAsyncRequestWith(withParam: ["sessionId": session?._id ?? "", "date": getCurrentDate() ?? ""], httpMethod: .post, apiName: .updatestats, showHud: true) { (data, response, error) in
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
                          self.healingMinuteLabel.text = healingTime.description
                      }
                      
                      if let healingDays = userDict?["healingDays"] as? Int {
                          processodDict["healingDays"] = healingDays
                          self.healingDayLabel.text = healingDays.description
                      }
                      
                      if let currentStreak = userDict?["currentStreak"] as? Int {
                          processodDict["currentStreak"] = currentStreak
                          self.currentStreakLabel.text = currentStreak.description
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
    
    
    override func viewDidAppear(_ animated: Bool) {
        autherImage.layer.cornerRadius = autherImage.bounds.width/2
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func gotoHomeAction() {
        self.dismiss(animated: true) {
            DispatchQueue.main.async {
                self.delegate?.popToRootVC()
            }
        }
    }
    
    
    @IBAction func openAutherLink() {
        if let urlString = session?.sessionAuthor?.authorWebsite {
            if urlString.contains("http") {
                guard let url = URL.init(string: (urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")) else { return }
                UIApplication.shared.open(url)
            } else {
                guard let url = URL.init(string:"https://\( (urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""))") else { return }
                UIApplication.shared.open(url)
            }
        }
    }
    
    
    @IBAction func rateButtonPressed(sender: UIButton) {
        let rateTillValue = sender.tag
        print(rateTillValue)
        for value in 0...4 {
            if value <= rateTillValue {
                rateBUttonCollection[value].setImage(#imageLiteral(resourceName: "icn_star_gold"), for: .normal)
            } else {
                rateBUttonCollection[value].setImage(#imageLiteral(resourceName: "icn_star_grey"), for: .normal)
            }
        }
        
        ServiceHelper.shared.sendAsyncRequestWith(withParam: ["rating":(rateTillValue + 1).description,"sessionId": session?._id ?? ""], httpMethod: .post, apiName: .ratesession, showHud: true) { (data, response, error) in

                   if let httpResponse = response as? HTTPURLResponse {
                       if httpResponse.statusCode == 200 {
                           guard let jsonData = data else {return}
                           self.showMessageWithData(withData: jsonData)
                       } else {
                            guard let jsonData = data else {return}
                            self.showMessageWithData(withData: jsonData)
                       }
                   }
               }
    }
    
    func showMessageWithData(withData data:Data) {
        do {
            let userDict =  try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                DispatchQueue.main.async {
                   if let message = userDict?["message"] as? String {
//                    self.showlAlet(title: "Message!", message: message)
                    self.showToast(message: message, font: .systemFont(ofSize: 14))
                    
                }
            }
        }catch {}
    }
    
    
    @IBAction func shareAction(){
        homeButton.isHidden = true
        sharebutton.isHidden = true
        let tempImage = UIImageView()
        let layer = view.layer
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, view.contentScaleFactor)
        guard let context = UIGraphicsGetCurrentContext() else {return }
        layer.render(in:context)
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            tempImage.image = image
        }
        UIGraphicsEndImageContext()
        homeButton.isHidden = false
        sharebutton.isHidden = false
        let imageToShare = [tempImage.image]
        let activityViewController = UIActivityViewController(activityItems: imageToShare as [Any], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash

        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook , UIActivity.ActivityType.postToTwitter]

        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }

}

extension UIViewController {

func showToast(message : String, font: UIFont) {

    let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 125, y: self.view.frame.size.height-100, width: 200, height: 35))
    toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    toastLabel.textColor = UIColor.white
    toastLabel.font = font
    toastLabel.textAlignment = .center;
    toastLabel.text = message
    toastLabel.alpha = 1.0
    toastLabel.layer.cornerRadius = 10;
    toastLabel.clipsToBounds  =  true
    self.view.addSubview(toastLabel)
    UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
         toastLabel.alpha = 0.0
    }, completion: {(isCompleted) in
        toastLabel.removeFromSuperview()
    })
} }
