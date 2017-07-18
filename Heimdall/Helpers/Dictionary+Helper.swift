//
//  Dictionary+Helper.swift
//  Heimdall
//
//  Created by Marius Ilie on 18/07/2017.
//  Copyright © 2017 Marius Ilie. All rights reserved.
//

import Foundation

extension Dictionary where Value: Any {
    func locate(path: String?, showEmptyPathError: Bool = true) -> Dictionary<Key, Value>? {
        var json = self
        
        guard path != "" else {
            if showEmptyPathError {
                printError(NSLocalizedString("Empty path", comment: ""))
            }
            return nil
        }
        
        guard let path = path else {
            printError(NSLocalizedString("Invalid path:", comment: ""))
            return nil
        }
        
        let paths = path.components(separatedBy: Defaults.jsonKeySeparator)
        
        for key in paths {
            guard let dictKey = key as? Key else {
                printError(key + NSLocalizedString("JSON Key value can't be converted into dictionary object", comment: ""))
                return nil
            }
            
            guard let newJSON = json[dictKey] as? Dictionary<Key, Value> else {
                printError(NSLocalizedString("Invalid path:", comment: "") + " " +  path)
                return nil
            }
            
            json = newJSON
        }
        
        return json
    }
    
    func findValue(path: String?) -> Any? {
        guard var path = path else {
            printError(NSLocalizedString("Invalid path:", comment: ""))
            return nil
        }
        
        var objectkey = path
        
        if let range = path.range(of: Defaults.jsonKeySeparator, options: .backwards)?.upperBound {
            objectkey = path.substring(from: range)
            path = path.replacingOccurrences(of: Defaults.jsonKeySeparator + objectkey, with: "")
        } else {
            path = path.replacingOccurrences(of: objectkey, with: "")
        }
        
        let json = self.locate(path: path, showEmptyPathError: false)
        
        guard let dictKey = objectkey as? Key else {
            printError(objectkey + NSLocalizedString("JSON Key value can't be converted into dictionary object", comment: ""))
            return nil
        }
        
        return json?[dictKey] ?? self[dictKey]
    }
}
