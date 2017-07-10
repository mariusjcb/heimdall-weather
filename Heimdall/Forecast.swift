//
//  Forecast.swift
//  Heimdall
//
//  Created by Marius Ilie on 11/07/2017.
//  Copyright © 2017 Marius Ilie. All rights reserved.
//

import Foundation

class Forecast: RequestJSONDecodable
{
    weak var location: Location?
    var time: Date
    
    let weather: String
    let icon: String
    
    let highCelsius: Double
    let lowCelsius: Double
    
    let highFahrenheit: Double
    let lowFahrenheit: Double
    
    //MARK: - Failable Initializer
    private init(json: Any) throws {
        let forecastAPI = Defaults.RestAPI.ForecastAPI.self
        
        guard let json = json as? [String: Any] else {
            printError(NSLocalizedString("JSON can't be converted into a dictionary", comment: ""))
            throw SerializationError.missing(NSLocalizedString("Main JSON", comment: ""))
        }
        
        guard let weather = json.findValue(path: forecastAPI.weather) as? String else {
            throw SerializationError.missing(forecastAPI.weather)
        }
        
        guard let icon = json.findValue(path: forecastAPI.icon) as? String else {
            throw SerializationError.missing(forecastAPI.icon)
        }
        
        guard let highCelsius = ToDouble(from: json.findValue(path: forecastAPI.highCelsiusTemp)) else {
            throw SerializationError.missing(forecastAPI.highCelsiusTemp)
        }
        
        guard let lowCelsius = ToDouble(from: json.findValue(path: forecastAPI.lowCelsiusTemp)) else {
            throw SerializationError.missing(forecastAPI.lowCelsiusTemp)
        }
        
        guard let highFahrenheit = ToDouble(from: json.findValue(path: forecastAPI.highFahrenheitTemp)) else {
            throw SerializationError.missing(forecastAPI.highFahrenheitTemp)
        }
        
        guard let lowFahrenheit = ToDouble(from: json.findValue(path: forecastAPI.lowFahrenheitTemp)) else {
            throw SerializationError.missing(forecastAPI.lowFahrenheitTemp)
        }
        
        guard let hour = json.findValue(path: forecastAPI.hour) as? Int else {
            throw SerializationError.missing(forecastAPI.hour)
        }
        
        guard let minutes = json.findValue(path: forecastAPI.minutes) as? String else {
            throw SerializationError.missing(forecastAPI.minutes)
        }
        
        guard let day = json.findValue(path: forecastAPI.day) as? Int else {
            throw SerializationError.missing(forecastAPI.day)
        }
        
        guard let month = json.findValue(path: forecastAPI.month) as? Int else {
            throw SerializationError.missing(forecastAPI.month)
        }
        
        guard let year = json.findValue(path: forecastAPI.year) as? Int else {
            throw SerializationError.missing(forecastAPI.year)
        }
        
        self.weather = weather
        self.icon = icon
        self.highCelsius = highCelsius
        self.lowCelsius = lowCelsius
        self.highFahrenheit = highFahrenheit
        self.lowFahrenheit = lowFahrenheit
        
        self.location = nil
        self.time = Date(hour, minutes, year, month, day, self.location?.timeOffset ?? String(describing: TimeZone.current.secondsFromGMT()))
    }
    
    required convenience init(json: Any, request: DataManager.Request) throws {
        try self.init(json: json)
        
        guard let location = WeatherDataManager.shared.locations.get(by: request) else {
            throw SerializationError.message(
                NSLocalizedString("Runtime Exception", comment: ""),
                NSLocalizedString("Requested location not exist into WeatherDataManager, call condition API first.", comment: "")
            )
        }
        
        self.location = location
    }
}

extension Array where Element: Forecast {
    init(json: Any, request: DataManager.Request) throws {
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
            let condition = try Forecast(json: forecastJSON, request: request)
            
            if let element = condition as? Element {
                self.append(element)
            }
        }
    }
}
