//
//  ForgotPasswordViewController.swift
//  Light
//
//  Created by apple on 08/04/20.
//  Copyright © 2020 Seraphic. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController {
    @IBOutlet var emailTf:UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backBttnAction() {  
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func forgotPasswordAction() {
        guard let email = emailTf.text else {
                 return
             }
             
             if email.validateEmail() == false  {
                 return
             }
             
              let params:[String:Any] = ["email":email]
              
              ServiceHelper.shared.sendAsyncRequestWith(withParam: params, httpMethod: .post, apiName: .forgotPassword, showHud: true) { (data, respose, error) in
                  
                  if let httpResponse = respose as? HTTPURLResponse {
                      if httpResponse.statusCode == 200 {
                        guard let jsonData = data else {return}
                        do {
                         let userDict =  try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
                            if let message = userDict?["message"] as? String {
                                 self.navigationController?.popViewController(animated: true)
                                DispatchQueue.main.async {
                                  self.showlAlet(title: "Success", message: message)
                                   
                              }
                            }
                        }catch{}
                         
                      } else {
                           DispatchQueue.main.async {
                            self.showlAlet(title: "Error!", message: error?.localizedDescription)
                          }
                      }
                  }
              }
    }
}
