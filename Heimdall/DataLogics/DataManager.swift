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
    
    
    
    /**
     **Handler api calls**
     
     This function is not responsible to process the json but on a
     success response it's automatically called the **process** method
     
     The completion handler will receive all fetching errors from this function
     
     - parameter data: **Optional(**Data**)**, the body of response
     - parameter response: **Optional(**URLResponse**)**, the api of response with headers
     - parameter error: **Optional(**Error**)**, the error received
     - parameter handler: **Optional(**APIDataCompletion**)**, your completion handler
     */
    
    func didFetch(data: Data?, response: URLResponse?, request: APIRequest, error: Error?, handler: APIDataCompletion? = nil)
    {
        if let handler = handler, let _ = error
        {
            // requesting error
            
            printError(NSLocalizedString("Failed requesting RestAPI", comment: ""))
            handler(nil, request, .failedAPIRequest)
            
            return
        } else if let data = data, let response = response as? HTTPURLResponse
        {
            // data received
            
            if response.statusCode == 200 {
                
                // all it's ok
                
                process(data: data, request: request, handler: handler)
                
            } else if let handler = handler {
                
                // error
                
                printError(NSLocalizedString("Wrong RestAPI response", comment: ""))
                
                handler(nil, request, .failedAPIRequest)
            }
            
        } else if let handler = handler {
            
            // unknown error
            
            printError(NSLocalizedString("Unknown Error", comment: ""))
            
            handler(nil, request, .unknown)
        }
    }
    
    
    
    
    /**
     **This method actually start processing JSON**
     
     This function is responsable to call DataBuilder.deserialize
     
     Attention:
     ==========
     When completion handler is nill:
     * You can't receive the error messages
     * The DataBuilder.deserialize is not called
     
     - parameter data: Data, the body of response / json
     - parameter request: APIRequest, your request
     - parameter handler: **Optional(**APIDataCompletion**)**, your completion handler
     */
    
    func process(data: Data, request: APIRequest, handler: APIDataCompletion? = nil)
    {
        guard let handler = handler else {
            printError(NSLocalizedString("Data processing need a handler", comment: ""))
            return
        }
        
        
        // process json
        
        DataBuilder.deserialize(json: data, request: request, serializationHandler: handler)
    }
}



/**
 Errors from DataManager methods
 */
enum DataManagerError: Error {
    case unknown
    case failedAPIRequest
    case invalidResponse
    case invalidData
    case invalidEndpoint
}
