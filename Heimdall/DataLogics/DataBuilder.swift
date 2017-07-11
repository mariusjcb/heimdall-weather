//
//  DataBuilder.swift
//  Heimdall
//
//  Created by Marius Ilie on 08/07/2017.
//  Copyright © 2017 Marius Ilie. All rights reserved.
//

import Foundation

enum SerializationError: Error {
    case missing(String)
    case message(String, String)
    case unknown
}

protocol JSONDecodable: NSCoding {
    init(json: Any) throws
}


final class DataBuilder
{
    typealias DataBuilderCompletion = (_ json: Any?, _ from: Defaults.RestAPI.EndPoints, _ error: SerializationError?) -> Void
    
    static func deserialize(json data: Data?, request: DataManager.APIRequest, serializationHandler: DataManager.APIDataCompletion)
    {
        guard let data = data else {
            printError(NSLocalizedString("Data is nil", comment: ""))
            
            serializationHandler(nil, request, .invalidData)
            return
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
            printError(NSLocalizedString("Data exists but JSON can't be deserialized", comment: ""))
    
            serializationHandler(nil, request, .invalidResponse)
            return
        }
        
        serializationHandler(json, request, nil)
    }
}

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
