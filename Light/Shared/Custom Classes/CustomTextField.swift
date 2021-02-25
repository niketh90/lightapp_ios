//
//  CustomTextField.swift
//  Light
//
//  Created by apple on 08/04/20.
//  Copyright © 2020 Seraphic. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class CustomTextField : UITextField {
    
    @IBInspectable var image: UIImage?
    @IBInspectable var placeholderColor: UIColor?
    
    override func draw(_ rect: CGRect) {
        if let image = image {
            self.setLeftIcon(image)
        }
        if let color = placeholderColor {
            self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "", attributes:[NSAttributedString.Key.foregroundColor: color])
        }
    }
    
}
