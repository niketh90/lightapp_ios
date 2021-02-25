//
//  Extension + UITextField.swift
//  massMobileMassage
//
//  Created by apple on 13/03/20.
//  Copyright © 2020 Seraphic. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
 
    func setLeftIcon(_ image: UIImage) {
        let iconView = UIImageView(frame:
            CGRect(x: 10, y: 5, width: 20, height: 20))
        iconView.image = image
        iconView.contentMode = .scaleAspectFit
        let iconContainerView: UIView = UIView(frame:
            CGRect(x: 20, y: 0, width: 40, height: 30))
        iconContainerView.addSubview(iconView)
        self.leftView = iconContainerView
        self.leftViewMode = .always
    }
    

    func setLeftPadding() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: self.frame.size.height))
        self.leftView = view
        self.leftViewMode = .always
    }
    

}

