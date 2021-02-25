//
//  AboutViewController.swift
//  Light
//
//  Created by apple on 09/04/20.
//  Copyright © 2020 Seraphic. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    @IBOutlet var profileImage:UIImageView!
    @IBOutlet var userNameLabel:UILabel!
    @IBOutlet var versionLabel:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let profileDetail = getUserDetails()
        userNameLabel.text = "\(profileDetail?.firstName ?? "") \(profileDetail?.lastName ?? "")"
        profileImage.sd_setImage(with: URL.init(string: profileDetail?.profileImage ?? ""), placeholderImage: UIImage.init(named: "img_avatar_camera"), options: .refreshCached, completed: nil)
        versionLabel.text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        if #available(iOS 12.0, *) {
                 self.navigationController?.navigationBar.barTintColor = UIColor.bgColor
             }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func goBackAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func goHomeAction() {
        self.dismiss(animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func privacyPolicyBttnAction() {
        let vc : WebviewViewController = WebviewViewController.instantiate()
        vc.isPrivacy = true
        vc.isPresented = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func termconditionsBttnAction() {
        let vc : WebviewViewController = WebviewViewController.instantiate()
        vc.isPrivacy = false
        vc.isPresented = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
