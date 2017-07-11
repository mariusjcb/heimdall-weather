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
    typealias APIRequestParams = [Defaults.RestAPI.DynamicVariables: String]
    typealias APIRequest = (Defaults.RestAPI.EndPoints, Defaults.RestAPI.QueryFormat, APIRequestParams)
    typealias APIDataCompletion = (_ json: Any?, _ from: APIRequest, _ error: DataManagerError?) -> ()
    
    func didFetch(data: Data?, response: URLResponse?, request: APIRequest, error: Error?, handler: APIDataCompletion? = nil)
    {
        if let handler = handler, let _ = error
        {
            printError(NSLocalizedString("Failed requesting RestAPI", comment: ""))
            handler(nil, request, .failedAPIRequest)
            return
        } else if let data = data, let response = response as? HTTPURLResponse
        {
            if response.statusCode == 200 {
                process(data: data, request: request, handler: handler)
            } else if let handler = handler {
                printError(NSLocalizedString("Failed requesting RestAPI", comment: ""))
                handler(nil, request, .failedAPIRequest)
            }
        } else if let handler = handler {
            printError(NSLocalizedString("Unknown Error", comment: ""))
            handler(nil, request, .unknown)
        }
    }
    
    func process(data: Data, request: APIRequest, handler: APIDataCompletion? = nil)
    {
        guard let handler = handler else {
            if let json = String(data: data, encoding: String.Encoding.utf8) { printJSON(json) }
            else { printError(NSLocalizedString("Data object can't be represented as utf8", comment: "")) }
            
            return
        }
        
        DataBuilder.deserialize(json: data, request: request, serializationHandler: handler)
    }
}

protocol JSONDecodableByRequest: NSCoding {
    init(json: Any, request: DataManager.APIRequest) throws
}

enum DataManagerError: Error {
    case unknown
    case failedAPIRequest
    case invalidResponse
    case invalidData
    case invalidEndpoint
}
