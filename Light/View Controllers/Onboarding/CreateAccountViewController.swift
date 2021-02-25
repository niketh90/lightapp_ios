//
//  CreateAccountViewController.swift
//  Light
//
//  Created by apple on 07/04/20.
//  Copyright © 2020 Seraphic. All rights reserved.
//

import UIKit

class CreateAccountViewController: UIViewController {
    @IBOutlet var firstNaneTf:UITextField!
    @IBOutlet var lastNaneTf:UITextField!
    @IBOutlet var emailNameTf:UITextField!
    @IBOutlet var passwordTf:UITextField!

   
    //MARK: ViewLifecycle
  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    
    //MARK: USerDefined function
    func setupView() {
        
    }
    
    //MARK: Action
    @IBAction func backBttnAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func signUpAction() {
        guard let firstname = firstNaneTf.text else {
            return
        }
        
        guard let lastname = lastNaneTf.text else {
            return
        }
        
        guard let email = emailNameTf.text else {
            return
        }
        
        if email.validateEmail() == false  {
            return
        }
        
        guard let password = passwordTf.text else {
            return
        }
        
        let param = ["firstName":firstname, "lastName": lastname, "email": email, "password": password]
       
        ServiceHelper.shared.sendAsyncRequestWith(withParam: param, httpMethod: .post, apiName: .signUp, showHud: true ) { (data, response, error) in
         
            guard let jsonString = String(data: data ?? Data(), encoding: .utf8) else {return}

            if let responseDict = ServiceHelper.shared.convertToDictionary(text: jsonString) {
                if let statusCode = responseDict["statusCode"] as? Int, statusCode == 200 {
                    DispatchQueue.main.async {
                        self.showlAlet(title: "Success", message: responseDict["message"] as? String)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showlAlet(title: "Error", message: responseDict["message"] as? String)
                    }
                }
            }
        }
    }
}
