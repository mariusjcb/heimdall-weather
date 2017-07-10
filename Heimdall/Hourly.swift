//
//  Hourly.swift
//  Heimdall
//
//  Created by Marius Ilie on 09/07/2017.
//  Copyright © 2017 Marius Ilie. All rights reserved.
//

import Foundation

class Hourly: JSONDecodable
{
    let humidity: Double
    let weather: String
    let icon: String
    
    let time: Date
    
    let celsius: Double
    let celsiusFeels: Double
    
    let fahrenheit: Double
    let fahrenheitFeels: Double
    
    let windDirection: String
    let windDegrees: Double
    
    
    
    //MARK: - Failable Initializer
    required init(json: Any) throws {
        let hourlyAPI = Defaults.RestAPI.HourlyAPI.self
        
        guard let json = json as? [String: Any] else {
            printError(NSLocalizedString("JSON can't be converted into a dictionary", comment: ""))
            throw SerializationError.missing(NSLocalizedString("Main JSON", comment: ""))
        }
        
        guard let humidity = ToDouble(from: json.findValue(path: hourlyAPI.humidity)) else {
            throw SerializationError.missing(hourlyAPI.humidity)
        }
        
        guard let weather = json.findValue(path: hourlyAPI.weather) as? String else {
            throw SerializationError.missing(hourlyAPI.weather)
        }
        
        guard let icon = json.findValue(path: hourlyAPI.icon) as? String else {
            throw SerializationError.missing(hourlyAPI.icon)
        }
        
        guard let celsiusFeels = ToDouble(from: json.findValue(path: hourlyAPI.celsiusFeels)) else {
            throw SerializationError.missing(hourlyAPI.celsiusFeels)
        }
        
        guard let fahrenheitFeels = ToDouble(from: json.findValue(path: hourlyAPI.fahrenheitFeels)) else {
            throw SerializationError.missing(hourlyAPI.fahrenheitFeels)
        }
        
        guard let windDirection = json.findValue(path: hourlyAPI.windDirection) as? String else {
            throw SerializationError.missing(hourlyAPI.windDirection)
        }
        
        guard let celsiusTemp = ToDouble(from: json.findValue(path: hourlyAPI.celsiusTemp)) else {
            throw SerializationError.missing(hourlyAPI.celsiusTemp)
        }
        
        guard let fahrenheitTemp = ToDouble(from: json.findValue(path: hourlyAPI.fahrenheitTemp)) else {
            throw SerializationError.missing(hourlyAPI.fahrenheitTemp)
        }
        
        guard let windDegrees = ToDouble(from: json.findValue(path: hourlyAPI.windDegrees)) else {
            throw SerializationError.missing(hourlyAPI.windDegrees)
        }
        
        self.humidity = humidity
        self.weather = weather
        self.icon = icon
        self.celsius = celsiusTemp
        self.celsiusFeels = celsiusFeels
        self.fahrenheit = fahrenheitTemp
        self.fahrenheitFeels = fahrenheitFeels
        self.windDirection = windDirection
        self.windDegrees = windDegrees
        
        self.time = Date()
    }
}

extension Array where Element: Hourly {
    init(json: Any) throws {
        self.init()
        
        let keyPaths = Defaults.RestAPI.EndPoints.keyPaths.self
        
        guard let mainJSON = json as? [String: Any] else {
            printError(NSLocalizedString("JSON can't be converted into a dictionary", comment: ""))
            throw SerializationError.missing(NSLocalizedString("Main JSON", comment: ""))
        }
        
        guard let hoursArray = mainJSON.findValue(path: keyPaths[.hourly]!) as? [[String: Any]] else {
            printError(keyPaths[.hourly]! + " " + NSLocalizedString("Value can't be converted into Array object", comment: ""))
            let errorAPI = Defaults.RestAPI.ErrorAPI.self
            
            if let error = mainJSON.locate(path: keyPaths[.error]!) as? [String: String],
                let type = error[errorAPI.type],
                let description = error[errorAPI.description]
            {
                throw SerializationError.message(type, description)
            } else {
                throw SerializationError.missing(keyPaths[.hourly]!)
            }
        }
        
        for hourlyJSON in hoursArray {
            let condition = try Hourly(json: hourlyJSON)
            
            if let element = condition as? Element {
                self.append(element)
            }
        }
    }
}
