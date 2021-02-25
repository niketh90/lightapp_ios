//
//  CustomImageView.swift
//  Light
//
//  Created by apple on 09/04/20.
//  Copyright © 2020 Seraphic. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class CustomImageView: UIImageView {
    
    @IBInspectable var isRounded: Bool = true
    
    override func draw(_ rect: CGRect) {
        if isRounded {
            self.layer.cornerRadius = rect.height / 2
            self.clipsToBounds = true
        }
    }
    
}
