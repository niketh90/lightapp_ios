//
//  CustomNavBar.swift
//  Light
//
//  Created by apple on 07/04/20.
//  Copyright © 2020 Seraphic. All rights reserved.
//

import Foundation
import UIKit

class CustomNavBar: UIViewController {
    
    override func viewDidLoad() {
        setUpTransparentNavBar()
    }
    
    func setUpTransparentNavBar(){
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
        self.setBackButton()
        self.setNavBarTitleImageWithSettingIcon()
    }
    
    func setBackButton(){
        let backImage = #imageLiteral(resourceName: "icn_back_white")
        navigationController?.navigationBar.backIndicatorImage = backImage
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
        navigationController?.navigationBar.barTintColor = .bgColor
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .white
        navigationItem.backBarButtonItem = backItem
        
    }
    
    func setNavBarTitleImageWithSettingIcon() {
        let image = UIImageView(image: #imageLiteral(resourceName: "icn_logo_small"))
        navigationItem.titleView = image
        let settingsBttn = UIBarButtonItem(image: #imageLiteral(resourceName: "icn_settings_white"), style: .plain, target: self, action: #selector(openSettings))
        settingsBttn.tintColor = .white
        navigationItem.rightBarButtonItem = settingsBttn
    }
    
    @objc func openSettings() {
        
        
        let vc = SettingsViewController.instantiate()
        let navBar = UINavigationController(rootViewController: vc)
        navBar.modalPresentationStyle = .fullScreen
        navBar.isNavigationBarHidden = true
        self.present(navBar, animated: true, completion: nil)
    }
    
}
