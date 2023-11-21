//
//  UIColor+ext.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 21.11.2023.
//

import UIKit

extension UIColor {
    func isEqual(to color: UIColor) -> Bool {
        self.hexString == color.hexString
    }
    
    var hexString: String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return String(format:"#%06x", rgb)
    }
}
