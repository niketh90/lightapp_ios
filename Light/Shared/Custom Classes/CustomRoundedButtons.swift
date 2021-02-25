//
//  CustomRoundedButtons.swift
//  Light
//
//  Created by apple on 07/04/20.
//  Copyright © 2020 Seraphic. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class CustomRoundedButtonView : UIControl {
    
    @IBInspectable var image: UIImage?
    @IBInspectable var text: String?
    @IBInspectable var textColor: UIColor?
    
    override func draw(_ rect: CGRect) {
        self.layer.cornerRadius = rect.height / 2
        self.clipsToBounds = true
        setBGColorAndImage(rect: rect)
    }
    
    private func setBGColorAndImage(rect: CGRect) {
        DispatchQueue.main.async {
            switch self.tag {
            case 0:
                self.backgroundColor = UIColor.lightGray.withAlphaComponent(0.4)
            case 1:
                self.backgroundColor = UIColor.facebookBlue
            case 2:
                self.backgroundColor = UIColor.googleRed
            default:
                self.backgroundColor = UIColor.black
            }
        }
        
        let iv = UIImageView(frame: CGRect(x: 50, y: 15, width: 30, height: rect.height - 30))
        iv.image = image
        iv.contentMode = .scaleAspectFit
        self.addSubview(iv)
        
        let lbl = UILabel(frame: CGRect(x: 100, y: 10, width: rect.width - 130, height: rect.height - 20))
        lbl.text = text
        lbl.textColor = textColor
        lbl.font = UIFont.setFont(type: .f500Rounded, of: 16)
        lbl.minimumScaleFactor = 10
        lbl.adjustsFontSizeToFitWidth = true
        lbl.numberOfLines = 1
        
        self.addSubview(lbl)
        
    }
    
}
