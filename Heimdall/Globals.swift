//
//  Globals.swift
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

func localPath(_ fileName: String) -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let documentsDirectory = paths[0]
    return documentsDirectory.appendingPathComponent(fileName)
}
