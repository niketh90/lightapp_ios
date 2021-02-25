//
//  Extentions + UIFonts.swift
//  Light
//
//  Created by apple on 07/04/20.
//  Copyright © 2020 Seraphic. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
    
    enum muesoSans: String {
        case f100 = "MuseoSans-100"
        case f300 = "MuseoSans-300"
        case f500 = "MuseoSans-500"
        case f700 = "MuseoSans-700"
        case f900 = "MuseoSans-900"
        case f100Rounded = "MuseoSansRounded-100"
        case c = "MuseoSansRounded-300"
        case f500Rounded = "MuseoSansRounded-500"
        case f700Rounded = "MuseoSansRounded-700"
        case f900Rounded = "MuseoSansRounded-900"
        case f1000Rounded = "MuseoSansRounded-1000"
        
    }
    
    static func setFont(type: muesoSans, of size: CGFloat) -> UIFont {
        return UIFont(name: type.rawValue, size: size)!
    }
    
}
