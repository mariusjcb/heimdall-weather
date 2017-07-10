//
//  Helpers.swift
//  Heimdall
//
//  Created by Marius Ilie on 08/07/2017.
//  Copyright © 2017 Marius Ilie. All rights reserved.
//

import Foundation

func printLog(_ string: String) {
    guard Defaults.logs else { return }
    #if DEBUG
        print(string)
    #endif
}

func printError(_ string: String) {
    printLog("(!) Error: \(string)")
}

func printJSON(_ json: String) {
    if Defaults.debugJSON == true {
        printLog("(JSON) Log:\n\(json)")
    }
}

func object(_ fromPlistFile: String, _ forKey: String) -> Any? {
    let filePath = Bundle.main.path(forResource: fromPlistFile, ofType: "plist")
    let plist = NSDictionary(contentsOfFile:filePath!)
    
    return plist?.object(forKey: forKey)
}

func ToDouble(from any: Any?) -> Double? {
    return (any as? String)?.toDouble() ?? (any as? Double)
}

extension Date {
    init(_ hour: String, _ minute: String, _ year: String, _ month: String, _ day: String, _ offset: String) {
        var string = Defaults.dateFormat
        string = string.replacingOccurrences(of: "HH", with: hour)
        string = string.replacingOccurrences(of: "mm", with: minute)
        
        string = string.replacingOccurrences(of: "yyyy", with: year)
        string = string.replacingOccurrences(of: "yy", with: year.substring(from: year.index(year.endIndex, offsetBy: -2)))
        
        string = string.replacingOccurrences(of: "MMMM", with: month)
        string = string.replacingOccurrences(of: "MMM", with: month)
        string = string.replacingOccurrences(of: "MM", with: month)
        
        string = string.replacingOccurrences(of: "EEEEEE", with: day)
        string = string.replacingOccurrences(of: "EEEEE", with: day)
        string = string.replacingOccurrences(of: "EEE", with: day)
        string = string.replacingOccurrences(of: "DD", with: day)
        string = string.replacingOccurrences(of: "dd", with: day)
        
        string = string.replacingOccurrences(of: "Z", with: offset)
        
        let formatter = DateFormatter()
        formatter.dateFormat = Defaults.dateFormat
        self = formatter.date(from: string) ?? Date()
    }
    
    init(_ hour: Int, _ minute: String, _ year: Int, _ month: Int, _ day: Int, _ offset: String) {
        let yStr = "\(year)"
        var hourStr: String = "\(hour)"
        var monthStr: String = "\(month)"
        var dayStr: String = "\(day)"
        
        if hour < 10 { hourStr = "0\(minute))" }
        if month < 10 { monthStr = "0\(minute))" }
        if day < 10 { dayStr = "0\(minute))" }
        
        self.init(hourStr, minute, yStr, monthStr, dayStr, offset)
    }
}

extension String {
    /**
     Replace variables like {VAR_NAME} from a "dynamic string"
     
     **All variables need to be uppercase**
     
     - parameter variable: The name of variable from DynamicString
     - parameter with: The string to replace varible from DynamicString
    */
    mutating func replace(variable: String, with replace: String) {
        self = self.replacingOccurrences(of: "{\(variable.uppercased())}", with: replace)
    }
    
    func toDouble(usingSeparator separator: String = ".") -> Double?
    {
        let formatter = NumberFormatter()
        formatter.decimalSeparator = separator
        
        return formatter.number(from: self.contains("-") ? "0.0" : self)?.doubleValue
    }
}

extension URL {
    /**
     Works like appendingPathComponent method but allow to append a URL Query
     
     **This function just create a new URL**
     
     - parameter path: The path which will append to the current relative URL
     */
    
    func append(_ path: String) -> URL? {
        let currentURLString = self.relativeString + path
        return URL(string: currentURLString)
    }
}
