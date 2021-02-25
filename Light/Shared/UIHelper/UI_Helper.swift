//
//  UI_Helper.swift
//  GimbelTest
//
//  Created by Jaskirat on 01/06/20.
//  Copyright © 2020 Jaskirat. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
           return layer.borderWidth
       }
       set {
           layer.borderWidth = newValue
       }
    }
    
    @IBInspectable var borderColor: UIColor? {
         get {
            return UIColor(cgColor: self.layer.borderColor!)
         }
         set {
            self.layer.borderColor = newValue?.cgColor
         }
    }
}
