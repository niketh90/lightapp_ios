//
//  AppDelegate.swift
//  Light
//
//  Created by apple on 07/04/20.
//  Copyright © 2020 Seraphic. All rights reserved.
//

import UIKit
import UserNotifications
import IQKeyboardManagerSwift
import FBSDKCoreKit
import GoogleSignIn
import AVFoundation
import FBSDKLoginKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var devicePushToken:String?
    var window : UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        FBSDKCoreKit.ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        UNUserNotificationCenter.current().delegate = self
        GIDSignIn.sharedInstance().clientID = "1074332195885-reunf48l7evvn32pmm7g01r0s430o3mo.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        
        IQKeyboardManager.shared.enable = true
        registerPushNotification()
        sleep(1)
        if getUserDetails() != nil {
            
            
            if #available(iOS 13.0, *) {
                let vc = Constants.mainStoryBoard.instantiateViewController(identifier: "HomeViewController") as? HomeViewController
                self.window?.rootViewController = vc
                
            } else {
                // Fallback on earlier versions
                let vc: HomeViewController =  HomeViewController.instantiate()
                let nVc = UINavigationController.init(rootViewController: vc)
                //nVc.navigationBar.isHidden = true
                 nVc.navigationBar.barTintColor = UIColor.clear
                self.setRootViewController(vc: nVc)
//                let vc = Constants.mainStoryBoard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController
//                self.window?.rootViewController = vc
            }
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
          try audioSession.setCategory(.playback, mode: .moviePlayback)
        }
        catch {
          print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
        
        ApplicationDelegate.shared.application(
            
            
            application,
            didFinishLaunchingWithOptions: launchOptions
        )

        return true
    }
    
    
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {

        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )

    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
//    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//        ApplicationDelegate.shared.application(app, open: url, options: options)
//    }

    func registerPushNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (isGranted, err) in
             if let error = err {
                   print("D'oh: \(error.localizedDescription)")
               } else {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                    
               }
        }
    }
    
    func setRootViewController(vc:UIViewController?){
        window = UIApplication.shared.windows.first
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceToken: String = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
           print("Device token is: \(deviceToken)")
        devicePushToken =  deviceToken
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(response.notification.request.content.userInfo)
        completionHandler()
    }
    
}

extension AppDelegate : GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
          if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
            print("The user has not signed in before or they have since signed out.")
          } else {
            print("\(error.localizedDescription)")
          }
          return
        }
        // Perform any operations on signed in user here.
//        let userId = user.userID                  // For client-side use only!
//        let idToken = user.authentication.idToken // Safe to send to the server
//        let fullName = user.profile.name
//        let givenName = user.profile.givenName
//        let familyName = user.profile.familyName
//        let email = user.profile.email
        
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
      // Perform any operations when the user disconnects from app here.
      // ...
    }
    
}
