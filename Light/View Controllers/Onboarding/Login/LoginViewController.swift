//
//  LoginViewController.swift
//  Light
//
//  Created by apple on 08/04/20.
//  Copyright © 2020 Seraphic. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet var emailNameTf:UITextField!
    @IBOutlet var passwordTf:UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func backBttnAction() {
        self.navigationController?.popViewController(animated: true)
    }

    //MARK: UserDefines function
    func setUpView() {
        
    }
    
    //MARK: Action
    @IBAction func loginAction() {
        guard let email = emailNameTf.text else {
           return
       }
       
       if email.validateEmail() == false  {
           return
       }
       
       guard let password = passwordTf.text else {
           return
       }
        
        let params:[String:Any] = ["email":email,
                      "password":password,
                      "deviceType": "1",
                      "deviceToken": appDelegate().devicePushToken ?? ""]
        
        print(params)
        
        ServiceHelper.shared.sendAsyncRequestWith(withParam: params, httpMethod: .post, apiName: .login, showHud: true) { (data, respose, error) in
            
            if let httpResponse = respose as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    guard let jsonData = data else {return}
                    do {
                       let userData = try JSONDecoder().decode(UserModel.self, from: jsonData)
                        saveUserDetails(data: userData)
                        if getFirstTimeAppInstalled() == true {
                            DispatchQueue.main.async {
                                let vc =  HomeViewController.instantiate()
                                
                                let nVc = UINavigationController.init(rootViewController: vc)
                              //  nVc.navigationBar.isHidden = true
                                 nVc.navigationBar.barTintColor = UIColor.clear
                                appDelegate().setRootViewController(vc: nVc)
                            }
                        } else {
                            DispatchQueue.main.async {
                                let vc =  OnboardingViewController.instantiate()
                                vc.modalPresentationStyle = .fullScreen
                                self.present(vc, animated: true, completion: nil)
                            }
                        }
                        
                    } catch {}
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
    
    @IBAction func forgotPassWordAction() {
    
    }
}
