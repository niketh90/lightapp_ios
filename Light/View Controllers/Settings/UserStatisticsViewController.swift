//
//  UserStatisticsViewController.swift
//  Light
//
//  Created by apple on 09/04/20.
//  Copyright © 2020 Seraphic. All rights reserved.
//

import UIKit

class UserStatisticsViewController: UIViewController {

    @IBOutlet var profileImage:UIImageView!
    @IBOutlet var userNameLabel:UILabel!
    @IBOutlet var currentStreakLabel:UILabel!
    @IBOutlet var healingDaysLabel:UILabel!
    @IBOutlet var healingMinutesLabel:UILabel!
    
    @IBOutlet var contentView:UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        profileImage.layer.cornerRadius = profileImage.bounds.width/2
               let profileDetail = getUserDetails()
                       userNameLabel.text = "\(profileDetail?.firstName ?? "") \(profileDetail?.lastName ?? "")"
                       profileImage.sd_setImage(with: URL.init(string: profileDetail?.profileImage ?? ""), placeholderImage: UIImage.init(named: "img_avatar_camera"), options: .refreshCached, completed: nil)
               currentStreakLabel.text = profileDetail?.currentStreak?.description ?? ""
               healingDaysLabel.text = profileDetail?.healingDays?.description ?? ""
               healingMinutesLabel.text = profileDetail?.healingTime?.description ?? ""
        
        if #available(iOS 12.0, *) {
                 self.navigationController?.navigationBar.barTintColor = UIColor.bgColor
             }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
    }
    
    @IBAction func goBackAction() {
        self.navigationController?.popViewController(animated: true)
    }
  
    @IBAction func shareAction() {
        let tempImage = UIImageView()
        contentView.backgroundColor = UIColor.init(named: "StatisticsFontColor")
        let layer = contentView.layer
        UIGraphicsBeginImageContextWithOptions(contentView.frame.size, false, contentView.contentScaleFactor)
        guard let context = UIGraphicsGetCurrentContext() else {return }
        layer.render(in:context)
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            tempImage.image = image
        }
        UIGraphicsEndImageContext()
        contentView.backgroundColor = .clear
        let imageToShare = [tempImage.image]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash

        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook , UIActivity.ActivityType.postToTwitter]

        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func goHomeAction() {
        self.dismiss(animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
}
