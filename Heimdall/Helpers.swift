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
