//
//  DataManager.swift
//  Heimdall
//
//  Created by Marius Ilie on 08/07/2017.
//  Copyright © 2017 Marius Ilie. All rights reserved.
//

import Foundation

class DataManager
{
    typealias RequestParams = [Defaults.RestAPI.DynamicVariables: String]
    typealias Request = (Defaults.RestAPI.EndPoints, Defaults.RestAPI.QueryFormat, RequestParams)
    typealias DataCompletion = (_ json: Any?, _ from: Request, _ error: DataManagerError?) -> ()
    
    func didFetch(data: Data?, response: URLResponse?, request: Request, error: Error?, handler: DataCompletion? = nil)
    {
        if let handler = handler, let _ = error
        {
            printError(NSLocalizedString("Failed requesting RestAPI", comment: ""))
            handler(nil, request, .failedRequest)
            return
        } else if let data = data, let response = response as? HTTPURLResponse
        {
            if response.statusCode == 200 {
                process(data: data, request: request, handler: handler)
            } else if let handler = handler {
                printError(NSLocalizedString("Failed requesting RestAPI", comment: ""))
                handler(nil, request, .failedRequest)
            }
        } else if let handler = handler {
            printError(NSLocalizedString("Unknown Error", comment: ""))
            handler(nil, request, .unknown)
        }
    }
    
    func process(data: Data, request: Request, handler: DataCompletion? = nil)
    {
        guard let handler = handler else {
            if let json = String(data: data, encoding: String.Encoding.utf8) { printJSON(json) }
            else { printError(NSLocalizedString("Data object can't be represented as utf8", comment: "")) }
            
            return
        }
        
        DataBuilder.deserialize(json: data, request: request, serializationHandler: handler)
    }
}

protocol RequestJSONDecodable {
    init(json: Any, request: DataManager.Request) throws
}

enum DataManagerError: Error {
    case unknown
    case failedRequest
    case invalidResponse
    case invalidData
    case invalidEndpoint
}
