//
//  NSTimeIntervalExtensions.swift
//  SwiftHelperKit
//
//  Copyright © 2015 Sebastian Volland. All rights reserved.
//

import Foundation

public extension NSTimeInterval {

    public var formatTimeLeft: String? {
        if self.isNaN || self == Double.infinity {
            return nil
        }

        if self < 0 {
            return nil
        }

        if self <= 59 {
            return "a few seconds"
        }

        let hours = Int(round(self / 3600))
        let minutes = Int(round((self % 3600) / 60))

        if hours <= 0 && minutes <= 0 {
            return nil
        }

        if hours == 1 {
            return "1 hour"
        }

        if hours > 1 {
            return "\(hours) hours"
        }

        if minutes == 1 {
            return "1 minute"
        }
        
        return "\(minutes) minutes"
    }
    
}
