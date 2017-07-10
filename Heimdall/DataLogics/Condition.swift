//
//  Condition.swift
//  Heimdall
//
//  Created by Marius Ilie on 08/07/2017.
//  Copyright © 2017 Marius Ilie. All rights reserved.
//

import Foundation

class Condition: JSONDecodable
{
    unowned let location: Location
    
    let uv: Double
    let humidity: String
    let weather: String
    let icon: String
    
    let time: Date
    
    let celsius: Double
    let celsiusFeels: Double
    
    let fahrenheit: Double
    let fahrenheitFeels: Double
    
    let todayPrecipitationPerInch: Double
    let todayPrecipitationMetric: Double
    
    let todayPrecipitationPerHourInch: Double
    let todayPrecipitationPerHourMetric: Double
    
    let windDirection: String
    let windDegrees: Double
    let windMpH: Double
    let windKpH: Double
    
    let pressureInch: Double
    let pressureMetric: Double
    
    
    
    //MARK: - Failable Initializer
    required init(json: Any) throws {
        let keyPaths = Defaults.RestAPI.EndPoints.keyPaths.self
        let conditionAPI = Defaults.RestAPI.ConditionAPI.self
        
        guard let mainJSON = json as? [String: Any] else {
            printError(NSLocalizedString("JSON can't be converted into a dictionary", comment: ""))
            throw SerializationError.missing(NSLocalizedString("Main JSON", comment: ""))
        }
        
        guard let json = mainJSON.locate(path: keyPaths[.conditions]!) else {
            printError(keyPaths[.conditions]! + " " + NSLocalizedString("JSON Key doesn't exist or can't be converted into dictionary object", comment: ""))
            let errorAPI = Defaults.RestAPI.ErrorAPI.self
            
            if let error = mainJSON.locate(path: keyPaths[.error]!) as? [String: String],
                let type = error[errorAPI.type],
                let description = error[errorAPI.description]
            {
                throw SerializationError.message(type, description)
            } else {
                throw SerializationError.missing(keyPaths[.conditions]!)
            }
        }
        
        guard let uv = ToDouble(from: json.findValue(path: conditionAPI.uv)) else {
            throw SerializationError.missing(conditionAPI.uv)
        }
        
        guard let humidity = json.findValue(path: conditionAPI.humidity) as? String else {
            throw SerializationError.missing(conditionAPI.humidity)
        }
        
        guard let weather = json.findValue(path: conditionAPI.weather) as? String else {
            throw SerializationError.missing(conditionAPI.weather)
        }
        
        guard let icon = json.findValue(path: conditionAPI.icon) as? String else {
            throw SerializationError.missing(conditionAPI.icon)
        }
        
        guard let celsiusFeels = ToDouble(from: json.findValue(path: conditionAPI.celsiusFeels)) else {
            throw SerializationError.missing(conditionAPI.celsiusFeels)
        }
        
        guard let fahrenheitFeels = ToDouble(from: json.findValue(path: conditionAPI.fahrenheitFeels)) else {
            throw SerializationError.missing(conditionAPI.fahrenheitFeels)
        }
        guard let todayPrecipIn = ToDouble(from: json.findValue(path: conditionAPI.todayPrecipIn)) else {
            throw SerializationError.missing(conditionAPI.todayPrecipIn)
        }
        
        guard let todayPrecipMetric = ToDouble(from: json.findValue(path: conditionAPI.todayPrecipMetric)) else {
            throw SerializationError.missing(conditionAPI.todayPrecipMetric)
        }
        
        guard let hourPrecipPerInch = ToDouble(from: json.findValue(path: conditionAPI.hourPrecipPerInch)) else {
            throw SerializationError.missing(conditionAPI.hourPrecipPerInch)
        }
        
        guard let hourPrecipMetric = ToDouble(from: json.findValue(path: conditionAPI.hourPrecipMetric)) else {
            throw SerializationError.missing(conditionAPI.hourPrecipMetric)
        }
        
        guard let windDirection = json.findValue(path: conditionAPI.windDirection) as? String else {
            throw SerializationError.missing(conditionAPI.windDirection)
        }
        
        guard let pressureInch = ToDouble(from: json.findValue(path: conditionAPI.pressureInch)) else {
            throw SerializationError.missing(conditionAPI.pressureInch)
        }
        
        guard let pressureMetric = ToDouble(from: json.findValue(path: conditionAPI.pressureMetric)) else {
            throw SerializationError.missing(conditionAPI.pressureMetric)
        }
        
        guard let celsiusTemp = ToDouble(from: json.findValue(path: conditionAPI.celsiusTemp)) else {
            throw SerializationError.missing(conditionAPI.celsiusTemp)
        }
        
        guard let fahrenheitTemp = ToDouble(from: json.findValue(path: conditionAPI.fahrenheitTemp)) else {
            throw SerializationError.missing(conditionAPI.fahrenheitTemp)
        }
        
        guard let windDegrees = ToDouble(from: json.findValue(path: conditionAPI.windDegrees)) else {
            throw SerializationError.missing(conditionAPI.windDegrees)
        }
        
        guard let windMpH = ToDouble(from: json.findValue(path: conditionAPI.windMpH)) else {
            throw SerializationError.missing(conditionAPI.windMpH)
        }
        
        guard let windKpH = ToDouble(from: json.findValue(path: conditionAPI.windKpH)) else {
            throw SerializationError.missing(conditionAPI.windKpH)
        }
        
        let locationKeyPath = Defaults.RestAPI.LocationAPI.keyPaths[.conditions]!
        guard let locationJSON = json.locate(path: locationKeyPath) else {
            throw SerializationError.missing(locationKeyPath)
        }
        
        self.uv = uv
        self.humidity = humidity
        self.weather = weather
        self.icon = icon
        self.celsius = celsiusTemp
        self.celsiusFeels = celsiusFeels
        self.fahrenheit = fahrenheitTemp
        self.fahrenheitFeels = fahrenheitFeels
        self.todayPrecipitationPerInch = todayPrecipIn
        self.todayPrecipitationMetric = todayPrecipMetric
        self.todayPrecipitationPerHourInch = hourPrecipPerInch
        self.todayPrecipitationPerHourMetric = hourPrecipMetric
        self.windDirection = windDirection
        self.windDegrees = windDegrees
        self.windMpH = windMpH
        self.windKpH = windKpH
        self.pressureInch = pressureInch
        self.pressureMetric = pressureMetric
        
        self.time = Date()
        
        let location = try Location(json: locationJSON)
        
        self.location = WeatherDataManager.shared.locations.append(location: location)
        self.location.condition = self
        
        if self.location.longitude == LocationManager.shared.longitude && self.location.latitude == LocationManager.shared.latitude {
            WeatherDataManager.shared.currentLocation = self.location
        }
    }
}
