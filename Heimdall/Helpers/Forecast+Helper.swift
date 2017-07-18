//
//  Forecast+Helper.swift
//  Heimdall
//
//  Created by Marius Ilie on 18/07/2017.
//  Copyright © 2017 Marius Ilie. All rights reserved.
//

import Foundation

extension Array where Element: Forecast {
    init(json: Any, location: Location?) throws {
        self.init()
        
        let keyPaths = Defaults.RestAPI.EndPoints.keyPaths.self
        
        guard let mainJSON = json as? [String: Any] else {
            printError(NSLocalizedString("JSON can't be converted into a dictionary", comment: ""))
            throw SerializationError.missing(NSLocalizedString("Main JSON", comment: ""))
        }
        
        guard let forecastArray = mainJSON.findValue(path: keyPaths[.forecast]!) as? [[String: Any]] else {
            printError(keyPaths[.forecast]! + " " + NSLocalizedString("Value can't be converted into Array object", comment: ""))
            let errorAPI = Defaults.RestAPI.ErrorAPI.self
            
            if let error = mainJSON.locate(path: keyPaths[.error]!) as? [String: String],
                let type = error[errorAPI.type],
                let description = error[errorAPI.description]
            {
                throw SerializationError.message(type, description)
            } else {
                throw SerializationError.missing(keyPaths[.forecast]!)
            }
        }
        
        for forecastJSON in forecastArray {
            let condition = try Forecast(json: forecastJSON, location: location)
            
            if let element = condition as? Element {
                self.append(element)
            }
        }
    }
}
