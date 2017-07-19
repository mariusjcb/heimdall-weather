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
