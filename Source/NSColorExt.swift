//
//  NSColorExt.swift
//  SwiftHelperKit
//
//  Copyright © 2015 Sebastian Volland. All rights reserved.
//

// Based on https://github.com/yeahdongcn/UIColor-Hex-Swift/blob/master/UIColorExtension.swift

import Foundation
import Cocoa

extension NSColor {

    public convenience init(rgba: String) {
        var red:   CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue:  CGFloat = 0.0
        var alpha: CGFloat = 1.0

        guard rgba.hasPrefix("#") else {
            NSLog("NSColor rgbs: Invalid RGB string, missing '#' as prefix for \(rgba)")
            self.init(red:red, green:green, blue:blue, alpha:alpha)
            return
        }

        let index   = rgba.characters.index(rgba.startIndex, offsetBy: 1)
        let hex     = String(rgba[index...])
        let scanner = Scanner(string: hex)
        var hexValue: CUnsignedLongLong = 0

        guard scanner.scanHexInt64(&hexValue) else {
            NSLog("NSColor rgbs: Scan hex error for \(rgba)")
            self.init(red:red, green:green, blue:blue, alpha:alpha)
            return
        }

        switch hex.characters.count {
        case 3:
            red   = CGFloat((hexValue & 0xF00) >> 8)       / 15.0
            green = CGFloat((hexValue & 0x0F0) >> 4)       / 15.0
            blue  = CGFloat(hexValue & 0x00F)              / 15.0
        case 4:
            red   = CGFloat((hexValue & 0xF000) >> 12)     / 15.0
            green = CGFloat((hexValue & 0x0F00) >> 8)      / 15.0
            blue  = CGFloat((hexValue & 0x00F0) >> 4)      / 15.0
            alpha = CGFloat(hexValue & 0x000F)             / 15.0
        case 6:
            red   = CGFloat((hexValue & 0xFF0000) >> 16)   / 255.0
            green = CGFloat((hexValue & 0x00FF00) >> 8)    / 255.0
            blue  = CGFloat(hexValue & 0x0000FF)           / 255.0
        case 8:
            red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
            green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
            blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
            alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
        default:
            NSLog("Invalid RGB string, number of characters after '#' should be either 3, 4, 6 or 8")
        }

        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }

}
