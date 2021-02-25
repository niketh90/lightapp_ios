//
//  Constants.swift
//  Light
//
//  Created by apple on 07/04/20.
//  Copyright © 2020 Seraphic. All rights reserved.
//

import Foundation
import UIKit
import AuthenticationServices

typealias collectionViewMethods = UICollectionViewDelegate & UICollectionViewDelegateFlowLayout & UICollectionViewDataSource

@available(iOS 13.0, *)
typealias appleLoginMethodsAndDelegates = ASAuthorizationControllerDelegate & ASAuthorizationControllerPresentationContextProviding

struct GlobalVariable {
    static var isDailySession = false
}

class Constants: NSObject {
    var isDailySession = false

    static let mainStoryBoard:UIStoryboard = UIStoryboard.init(name: "Main", bundle: nil)

     var deviceToken:String?
    static func setNavBar() {
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().backgroundColor = .clear
    }
    
}

func appDelegate() -> AppDelegate {
    return UIApplication.shared.delegate as! AppDelegate
}


func saveUserDetails(data: UserModel) {
    let encoder = JSONEncoder()
    if let encoded = try? encoder.encode(data) {
        let defaults = UserDefaults.standard
        defaults.set(encoded, forKey: "user_Data")
        UserDefaults.standard.synchronize()
    }
}

func saveFirstTimeAppIntalled(value: Bool){
    let defaults = UserDefaults.standard
    defaults.set(value, forKey: "fresh_installed")
    UserDefaults.standard.synchronize()
}

func getFirstTimeAppInstalled() -> Bool{
   return  UserDefaults.standard.bool(forKey: "fresh_installed")
}


func emptyUserDetails() {
        let defaults = UserDefaults.standard
        defaults.set("", forKey: "user_Data")
        UserDefaults.standard.synchronize()
    
}


func getUserDetails() -> UserModel? {
    if let data =  UserDefaults.standard.object(forKey: "user_Data") as? Data   {
        let decoder = JSONDecoder()
        if let loadedPerson = try? decoder.decode(UserModel.self, from: data) {
            return loadedPerson
        }
    }
    return nil
}

func getCurrentDate() -> String? {
    let dateFormat = DateFormatter()
    dateFormat.dateFormat = "yyyy-MM-dd"
    dateFormat.timeZone = TimeZone.current
    return dateFormat.string(from: Date())
}

func getCurrentDateWithLocalTimeZone() -> Date {
    let dateformat = DateFormatter()
    dateformat.dateFormat = "yyyy-MM-dd HH:mm"
    dateformat.timeZone = TimeZone.current

    let currentStringDate = dateformat.string(from: Date())

    dateformat.timeZone = TimeZone.init(abbreviation: "UTC")

    return dateformat.date(from: currentStringDate) ?? Date()
}


func getSubscription(withDate date:String?, completion: @escaping ((_ success: Bool) -> Void)) {

    ServiceHelper.shared.sendAsyncRequestWith(withParam: ["date":date ?? ""], httpMethod: .post, apiName: .InApp_Verify, showHud: true) { (data, response, erro) in
        
        
        if let httpResponse = response as? HTTPURLResponse {
            
            
            if httpResponse.statusCode == 200 {
                guard let jsonData = data else {return}
                   do {
                    
                    
                        let dataDict =  try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
                        if let iosReceipt = dataDict?["androidReceipt"] as? [String:Any] {
                            let receiptData = try JSONSerialization.data(withJSONObject: iosReceipt)
                            let inAppModel:InAppModel?
                            inAppModel = try JSONDecoder().decode(InAppModel.self, from: receiptData)
                            print(inAppModel?.expiryTimeMillis ?? "")
                            let expiryDate = Double(inAppModel?.expiryTimeMillis ?? 0)
                            let date = Date(timeIntervalSince1970: (expiryDate / 1000.0))
                            
                            let currentDate = getCurrentDateWithLocalTimeZone()
                            let expirationDate = date.convertUtcToCurrent()
                            

                            print("\(currentDate)<><><>\(expirationDate)")
                            if expirationDate == currentDate {
                                print("same")
                                 completion(true)
                            }else if expirationDate > currentDate {
                                completion(true)
                            } else if expirationDate < currentDate {
                            completion(false)
                            }
                        } else {
                             completion(false)
                        }
                    } catch _ {
                        completion(false)
                }
            } else {
                
                completion(false)
            }
        }
    }
    
}

extension String {
    func validateEmail() -> Bool {
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
               return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
}

extension Date {
    func convertUtcToCurrent() -> Date {
        let dateformat = DateFormatter()
        dateformat.dateFormat = "yyyy-MM-dd HH:mm"
        dateformat.timeZone = TimeZone.current

        let currentStringDate = dateformat.string(from: self)

        dateformat.timeZone = TimeZone.init(abbreviation: "UTC")

        return dateformat.date(from: currentStringDate) ?? Date()
    }
}
