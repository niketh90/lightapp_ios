//
//  ViewController.swift
//  Light
//
//  Created by apple on 07/04/20.
//  Copyright © 2020 Seraphic. All rights reserved.
//

import UIKit
import AuthenticationServices
import FBSDKLoginKit
import GoogleSignIn

enum SocialLogin {
    case google
    case facebook
    case apple
}


class ViewController: UIViewController {
    
    @IBOutlet var loginProviderStackView: UIStackView!
    @IBOutlet var attributedLabel:UITextView!
    var loginType:SocialLogin?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
        if #available(iOS 13.0, *) {
            DispatchQueue.main.async {
                self.setupProviderLoginView()
            }
        } else {
            // Fallback on earlier versions
        }
        
        //Attributed text
        attributedLabel.text = "By continuing you agree to our Privacy policy and Terms and Conditions."
        let text = (attributedLabel.text)!
        let underlineAttriString = NSMutableAttributedString(string: text)
        let range1 = (text as NSString).range(of: "Terms and Conditions")
        underlineAttriString.addAttribute(.link, value:"1", range: range1)
        let range2 = (text as NSString).range(of: "Privacy policy")
        underlineAttriString.addAttribute(.link, value:"2", range: range2)

        attributedLabel.attributedText = underlineAttriString
 

    }
    
    //MARK: Webservices
    
    func socialSignIn(withToken token:String?,  loginWith:ApiName) {
        GIDSignIn.sharedInstance()?.signOut()

        let params:[String:Any] = ["access_token":token ?? "",
                      "deviceType": "1",
                      "deviceToken": appDelegate().devicePushToken ?? ""]
        
        ServiceHelper.shared.sendAsyncRequestWith(withParam: params, httpMethod: .post, apiName: loginWith, showHud: true) { (data, respose, error) in
            
            if let httpResponse = respose as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    guard let jsonData = data else {return}
                    do {
                       let userData = try JSONDecoder().decode(UserModel.self, from: jsonData)
                        saveUserDetails(data: userData)
                        
                        
                        DispatchQueue.main.async {
                          
                            if getFirstTimeAppInstalled() == true {
                                
                                let vc =  HomeViewController.instantiate()
                                let nVc = UINavigationController.init(rootViewController: vc)
                                //nVc.navigationBar.isHidden = true
                                 nVc.navigationBar.barTintColor = UIColor.clear
                                appDelegate().setRootViewController(vc: nVc)
                            } else {
                                
                                
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
    
    
    func googgleSignIn(withtoken token: String?) {
        GIDSignIn.sharedInstance()?.signOut()
        let params:[String:Any] = ["access_token":token ?? "",
                      "deviceType": "1",
                      "deviceToken": appDelegate().devicePushToken ?? ""]
        
        ServiceHelper.shared.sendAsyncRequestWith(withParam: params, httpMethod: .post, apiName: .googleSignIn, showHud: true) { (data, respose, error) in
            
            if let httpResponse = respose as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    guard let jsonData = data else {return}
                    do {
                       let userData = try JSONDecoder().decode(UserModel.self, from: jsonData)
                        saveUserDetails(data: userData)
                        DispatchQueue.main.async {
                          
                            
                            let vc =  HomeViewController.instantiate()
                              let nVc = UINavigationController.init(rootViewController: vc)
                           // nVc.navigationBar.isHidden = true
                             nVc.navigationBar.barTintColor = UIColor.clear
                            appDelegate().setRootViewController(vc: nVc)
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
    
    
    func facebookSignIn(withtoken token: String?) {
        let params:[String:Any] = ["access_token":token ?? "",
                      "deviceType": "1",
                      "deviceToken": appDelegate().devicePushToken ?? ""]
        
        ServiceHelper.shared.sendAsyncRequestWith(withParam: params, httpMethod: .post, apiName: .facebookSignIn, showHud: true) { (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    guard let jsonData = data else {return}
                    do {
                       let userData = try JSONDecoder().decode(UserModel.self, from: jsonData)
                        saveUserDetails(data: userData)
                        DispatchQueue.main.async {
                          
                            
                            let vc =  HomeViewController.instantiate()
                              let nVc = UINavigationController.init(rootViewController: vc)
                            //nVc.navigationBar.isHidden = true
                             nVc.navigationBar.barTintColor = UIColor.clear
                            appDelegate().setRootViewController(vc: nVc)
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
    
    //MARK: Action
    @IBAction func emailBttnAction(_ sender: UIControl) {
        let vc : CreateAccountViewController = CreateAccountViewController.instantiate()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func googleSignInBttnAction(_ sender: UIControl) {
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
        if GIDSignIn.sharedInstance()?.hasPreviousSignIn() ?? false {
            
            
            GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        } else {
            
            GIDSignIn.sharedInstance()?.signIn()
        }
    }
    
    @IBAction func fbLoginBttnAction(_ sender: UIControl) {
        let loginManager = LoginManager()
        //"user_photos", "public_profile", "email", "user_birthday"
        loginManager.logOut()
        
        loginManager.logIn(permissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error {
                print("Failed to login: \(error.localizedDescription)")
                return
            }
            guard let accessToken = AccessToken.current else {
                print("Failed to get access token")
                return
            }
            print(accessToken.tokenString)
            self.fetchDataFromFacebook(token: accessToken)
        }
    }
    
        
    func fetchDataFromFacebook(token: AccessToken) {
            let graphRequest : GraphRequest = GraphRequest(graphPath: "me", parameters: ["fields":"id, email, name, picture.width(480).height(480), first_name, last_name"])
            
            graphRequest.start { (connection, result, error) in
                if let _ = error {
//                    Error
                } else if let result = result as? [String: Any] {
                    
//                    let email: String = result["email"] as? String ?? ""
//                    let fbId: String = result["id"] as? String ?? ""
//                    let userName = result["name"] as? String
//                    var profilePicUrl = ""
//                    if let pictureDict = result["picture"] as? [String: Any] {
//                        if let dataDict = pictureDict["data"] as? [String: Any] {
//                            if let url = dataDict["url"] as? String {
//                                profilePicUrl = url
//                            }
//                        }
//                    }
//                    let firstName = result["first_name"] as? String ?? ""
//                    let lastName = result["last_name"] as? String ?? ""
                    let accessToken = token.tokenString
                    //self.facebookSignIn(withtoken: accessToken)
                    self.socialSignIn(withToken: accessToken, loginWith: .facebookSignIn)
                } else {
                 // Error
                    self.showlAlet(title: "Error!", message: error?.localizedDescription)
                }
            }
        }
    
    @available(iOS 13.0, *)
    func setupProviderLoginView() {
        DispatchQueue.main.async {
            let authorizationButton = ASAuthorizationAppleIDButton(type: .continue, style: .black)
            authorizationButton.addTarget(self, action: #selector(self.handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
            self.loginProviderStackView.addArrangedSubview(authorizationButton)
            authorizationButton.layer.cornerRadius = authorizationButton.frame.size.height / 2
            authorizationButton.clipsToBounds = true
        }
    }
    
    @available(iOS 13.0, *)
    @objc func handleAuthorizationAppleIDButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
}
extension ViewController : GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
            } else {
                print("\(error.localizedDescription)")
            }
            return
        }
        
        //    Perform any operations on signed in user here.
      //  let userId = user.userID                  // For client-side use only!
        let idToken = user.authentication.idToken // Safe to send to the server
//        let fullName = user.profile.name
//        let givenName = user.profile.givenName
//        let familyName = user.profile.familyName
//        let email = user.profile.email
       // googgleSignIn(withtoken: idToken)
        socialSignIn(withToken: idToken, loginWith: .googleSignIn)
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        self.showlAlet(title: "Error!", message: error.localizedDescription)
    }
}


@available(iOS 13.0, *)
extension ViewController: appleLoginMethodsAndDelegates {
    /// - Tag: did_complete_authorization
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        

        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            let authorizationProvider = ASAuthorizationAppleIDProvider()
            authorizationProvider.getCredentialState(forUserID: appleIDCredential.user) { (state, error) in
                switch (state) {
                case .authorized:
                    print("Account Found - Signed In")
                    break
                case .revoked:
                    print("No Account Found")
                    fallthrough
                case .notFound:
                     print("No Account Found")
                default:
                    break
                }
            }

            // Create an account in your system.
            let userIdentifier = appleIDCredential.user
            let authCode = appleIDCredential.authorizationCode
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            print("\(authCode ?? Data())")
            // For the purpose of this demo app, store the `userIdentifier` in the keychain.
            print(userIdentifier, fullName ?? "", email ?? "")
            let token = String(data: authCode ?? Data(), encoding: .utf8)
            socialSignIn(withToken: token, loginWith: .appleLogin)
//            self.saveUserInKeychain(userIdentifier)
            
            // For the purpose of this demo app, show the Apple ID credential information in the `ResultViewController`.
            //            self.showResultViewController(userIdentifier: userIdentifier, fullName: fullName, email: email)
            
        case let passwordCredential as ASPasswordCredential:
            
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            
            // For the purpose of this demo app, show the password credential as an alert.
            DispatchQueue.main.async {
                self.showPasswordCredentialAlert(username: username, password: password)
            }
            
        default:
            break
        }
    }
    
    //    private func showResultViewController(userIdentifier: String, fullName: PersonNameComponents?, email: String?) {
    //        guard let viewController = self.presentingViewController as? ViewController
    //            else { return }
    //
    //        DispatchQueue.main.async {
    //            viewController.userIdentifierLabel.text = userIdentifier
    //            if let givenName = fullName?.givenName {
    //                viewController.givenNameLabel.text = givenName
    //            }
    //            if let familyName = fullName?.familyName {
    //                viewController.familyNameLabel.text = familyName
    //            }
    //            if let email = email {
    //                viewController.emailLabel.text = email
    //            }
    //            self.dismiss(animated: true, completion: nil)
    //        }
    //    }
    
    
    private func showPasswordCredentialAlert(username: String, password: String) {
        let message = "The app has received your selected credential from the keychain. \n\n Username: \(username)\n Password: \(password)"
        let alertController = UIAlertController(title: "Keychain Credential Received",
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// - Tag: did_complete_error
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
    }
    
    /// - Tag: provide_presentation_anchor
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

extension ViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if URL.absoluteString == "1" {
            let vc : WebviewViewController = WebviewViewController.instantiate()
            vc.isPrivacy = false
            vc.isPresented = false
            self.navigationController?.pushViewController(vc, animated: true)
            return true

        } else if URL.absoluteString == "2" {
            let vc : WebviewViewController = WebviewViewController.instantiate()
            vc.isPrivacy = true
            vc.isPresented = false
            self.navigationController?.pushViewController(vc, animated: true)
            return true

        }
        return false
    }
 
}
