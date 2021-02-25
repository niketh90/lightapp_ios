//
//  SceneDelegate.swift
//  Light
//
//  Created by apple on 07/04/20.
//  Copyright © 2020 Seraphic. All rights reserved.
//

import UIKit
import FBSDKLoginKit

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var windowScene: UIWindowScene?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
                // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        Constants.setNavBar()
        guard let windowScene = (scene as? UIWindowScene) else { return }
        self.windowScene = windowScene
        
        // let window = UIWindow(windowScene: windowScene)
        sleep(1)
        if getUserDetails() != nil {
            guard let vc = Constants.mainStoryBoard.instantiateViewController(identifier: "HomeViewController") as? HomeViewController else{return}
            let nvc = UINavigationController.init(rootViewController: vc)
           // nvc.navigationBar.isHidden = true
             nvc.navigationBar.barTintColor = UIColor.clear
            self.window?.rootViewController = nvc
        }
    }
    
    
    //  SceneDelegate.swift
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }
        let _ = ApplicationDelegate.shared.application(
            UIApplication.shared,
            open: url,
            sourceApplication: nil,
            annotation: [UIApplication.OpenURLOptionsKey.annotation])
    }
    
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        print("did become active")
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        
        print("will enter foreground")
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("refreshSession"), object: nil)
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        
        print("enter background")
        
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
//<<<<<<< HEAD
    
    
//=======

//    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
//      guard let url = URLContexts.first?.url else {
//        return
//      }
//      let _ = ApplicationDelegate.shared.application(
//        UIApplication.shared,
//        open: url,
//        sourceApplication: nil,
//        annotation: [UIApplication.OpenURLOptionsKey.annotation])
//    }

//>>>>>>> master
}

