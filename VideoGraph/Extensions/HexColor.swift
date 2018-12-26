//
//  UIColor.swift
//  VideoGraph
//
//  Created by Admin on 13/08/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

struct RGBA32: Equatable {
    private var color: UInt32
    
    var redComponent: UInt8 {
        return UInt8((color >> 24) & 255)
    }
    
    var greenComponent: UInt8 {
        return UInt8((color >> 16) & 255)
    }
    
    var blueComponent: UInt8 {
        return UInt8((color >> 8) & 255)
    }
    
    var alphaComponent: UInt8 {
        return UInt8((color >> 0) & 255)
    }
    
    init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
        let red   = UInt32(red)
        let green = UInt32(green)
        let blue  = UInt32(blue)
        let alpha = UInt32(alpha)
        color = (red << 24) | (green << 16) | (blue << 8) | (alpha << 0)
    }
    
    static let red             = RGBA32(red: 255, green: 0,   blue: 0,   alpha: 255)
    static let green           = RGBA32(red: 0,   green: 255, blue: 0,   alpha: 255)
    static let blue            = RGBA32(red: 0,   green: 0,   blue: 255, alpha: 255)
    static let white           = RGBA32(red: 255, green: 255, blue: 255, alpha: 255)
    static let black           = RGBA32(red: 0,   green: 0,   blue: 0,   alpha: 255)
    static let magenta         = RGBA32(red: 255, green: 0,   blue: 255, alpha: 255)
    static let yellow          = RGBA32(red: 255, green: 255, blue: 0,   alpha: 255)
    static let cyan            = RGBA32(red: 0,   green: 255, blue: 255, alpha: 255)
    static let clear           = RGBA32(red: 0,   green: 0,   blue: 0,   alpha: 0)
    static let restore_overlay = RGBA32(red: 60,   green: 180,   blue: 100,   alpha: 100)
    
    static let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
    
    static func ==(lhs: RGBA32, rhs: RGBA32) -> Bool {
        return lhs.color == rhs.color
    }
    
    static func >=(lhs: RGBA32, rhs: RGBA32) -> Bool {
        return lhs.color >= rhs.color
    }

    static func <=(lhs: RGBA32, rhs: RGBA32) -> Bool {
        return lhs.color <= rhs.color
    }

}

extension UIColor {
    var redValue: Int { return Int(CIColor(color: self).red * 255.0) }
    var greenValue: Int { return Int(CIColor(color: self).green * 255.0) }
    var blueValue: Int { return Int(CIColor(color: self).blue * 255.0) }
    var alphaValue: Int { return Int(CIColor(color: self).alpha * 255.0) }

    convenience init(hex: UInt) {
        self.init(hex: hex, alpha:1)
    }

    convenience init(hex: UInt, alpha: CGFloat) {
        self.init(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0x0000FF) / 255.0,
            alpha: CGFloat(alpha)
        )
    }
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
    
    static func == (l: UIColor, r: UIColor) -> Bool {
        var r1: CGFloat = 0
        var g1: CGFloat = 0
        var b1: CGFloat = 0
        var a1: CGFloat = 0
        l.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        var r2: CGFloat = 0
        var g2: CGFloat = 0
        var b2: CGFloat = 0
        var a2: CGFloat = 0
        r.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        return r1 == r2 && g1 == g2 && b1 == b2 && a1 == a2
    }
}
