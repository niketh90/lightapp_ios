//
//  CustomButton.swift
//  Light
//
//  Created by apple on 08/04/20.
//  Copyright © 2020 Seraphic. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class CustomButton : UIButton {
    
    @IBInspectable var isRound: Bool = true
    
    override func draw(_ rect: CGRect) {
        if isRound {
            self.layer.cornerRadius = rect.height / 2
        }
    }
    
}
