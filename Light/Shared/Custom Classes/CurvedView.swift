//
//  CurvedView.swift
//  Light
//
//  Created by apple on 07/04/20.
//  Copyright © 2020 Seraphic. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class CurvedView: UIView {
    
     override func draw(_ rect: CGRect) {

        let myBezier = UIBezierPath()
        myBezier.move(to: CGPoint(x: 0, y: 0))
        
        
        myBezier.addArc(withCenter: CGPoint(x: 35, y: 0), radius: 35, startAngle: .pi * 2, endAngle: (.pi*2) + (.pi/2), clockwise: false)

        
        myBezier.addLine(to: CGPoint(x: rect.width - 35, y: 35))
                
        myBezier.addArc(withCenter: CGPoint(x: rect.width - 35, y: 70), radius: 35, startAngle: .pi/2, endAngle: .pi * 2, clockwise: true)
        
        myBezier.addLine(to: CGPoint(x: rect.width, y: rect.height))
        myBezier.addLine(to: CGPoint(x: 0, y: rect.height))
        
        myBezier.close()
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setLineWidth(4.0)
        
        UIColor.white.setFill()
        myBezier.fill()
    }
}
