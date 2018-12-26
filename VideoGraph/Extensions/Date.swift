//
//  NSDate.swift
//  VideoGraph
//
//  Created by Admin on 13/08/2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

extension Date {
    func convertToString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm" //"h:mm a"
        return dateFormatter.string(from: self)
    }
    
    func convertToString(_ format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }

    var age: Int {
        return Calendar.current.dateComponents([.year], from: self, to: Date()).year!
    }

    // Convert local time to UTC (or GMT)
    func toGlobalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = -TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    
    // Convert UTC (or GMT) to local time
    func toLocalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    
    func differenceInDaysWithDate(date: Date) -> Int {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        
        let components = calendar.dateComponents([.day], from: date, to: self)
        return components.day ?? 0
    }
    
    var millisecondsSince1970:Int64 {
        let milliSeconds = Int64((self.timeIntervalSince1970 * 1000).rounded())
        return milliSeconds
        //        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
}
