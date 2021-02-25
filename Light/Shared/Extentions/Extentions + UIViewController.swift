//
//  Extentions + UIViewController.swift
//  Light
//
//  Created by apple on 07/04/20.
//  Copyright © 2020 Seraphic. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    class func instantiate<T: UIViewController>() -> T {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let identifier = String(describing: self)
        return storyboard.instantiateViewController(withIdentifier: identifier) as! T
    }
   
    func showlAlet(title: String?, message: String?) {
        let alert = UIAlertController.init(title: title ?? "", message: message ?? "", preferredStyle: .alert)
        let action = UIAlertAction.init(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
