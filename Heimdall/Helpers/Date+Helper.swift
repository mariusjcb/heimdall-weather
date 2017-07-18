//
//  Date+Helper.swift
//  Heimdall
//
//  Created by Marius Ilie on 18/07/2017.
//  Copyright © 2017 Marius Ilie. All rights reserved.
//

import Foundation

extension Date {
    init(_ hour: String, _ minute: String, _ year: String, _ month: String, _ day: String, _ offset: String) {
        var dateString = Defaults.dateFormat
        dateString = dateString.replacingOccurrences(of: "HH", with: hour)
        dateString = dateString.replacingOccurrences(of: "mm", with: minute)
        
        dateString = dateString.replacingOccurrences(of: "yyyy", with: year)
        dateString = dateString.replacingOccurrences(of: "yy", with: year.substring(from: year.index(year.endIndex, offsetBy: -2)))
        
        dateString = dateString.replacingOccurrences(of: "MMMM", with: month)
        dateString = dateString.replacingOccurrences(of: "MMM", with: month)
        dateString = dateString.replacingOccurrences(of: "MM", with: month)
        
        dateString = dateString.replacingOccurrences(of: "EEEEEE", with: day)
        dateString = dateString.replacingOccurrences(of: "EEEEE", with: day)
        dateString = dateString.replacingOccurrences(of: "EEE", with: day)
        dateString = dateString.replacingOccurrences(of: "DD", with: day)
        dateString = dateString.replacingOccurrences(of: "dd", with: day)
        
        dateString = dateString.replacingOccurrences(of: "Z", with: offset)
        
        let formatter = DateFormatter()
        formatter.dateFormat = Defaults.dateFormat
        self = formatter.date(from: dateString) ?? Date()
    }
    
    init(_ hour: Int, _ minute: String, _ year: Int, _ month: Int, _ day: Int, _ offset: String) {
        let yStr = "\(year)"
        
        let hourStr = String(format: "%02d", hour)
        let monthStr = String(format: "%02d", Int(month))
        let dayStr = String(format: "%02d", day)
        
        self.init(hourStr, minute, yStr, monthStr, dayStr, offset)
    }
    
    func isToday() -> Bool {
        let calendar = Calendar.current
        return calendar.isDateInToday(self)
    }
}
