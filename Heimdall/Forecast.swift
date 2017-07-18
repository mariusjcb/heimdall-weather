//
//  Forecast.swift
//  Heimdall
//
//  Created by Marius Ilie on 11/07/2017.
//  Copyright © 2017 Marius Ilie. All rights reserved.
//

import Foundation

/**
 **This class implements NSCoding**
 
 
 You can use NSKeyedArchiver.archivedData:
 ```
 jsonDecodableObj = try JSONDecodableClass(json)
 
 UserDefaults.standard.set(
    NSKeyedArchiver.archivedData(
        withRootObject: location
    ),
    forKey: "yourKey"
 )
 
 ```
 */

@objc class Forecast: NSObject, JSONDecodableWithLocation
{
    //weak var location: Location?
    var time: Date
    
    let weather: String
    let icon: String
    
    let highCelsius: Double
    let lowCelsius: Double
    
    let highFahrenheit: Double
    let lowFahrenheit: Double
    
    
    //MARK: - Failable Initializer
    required init(json: Any, location: Location?) throws {
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
        
        self.time = Date(hour, minutes, year, month, day, location?.timeOffset ?? String(describing: TimeZone.current.secondsFromGMT()))
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        icon = aDecoder.decodeObject(forKey: "icon") as! String
        weather = aDecoder.decodeObject(forKey: "weather") as! String
        lowCelsius = aDecoder.decodeObject(forKey: "lowCelsius") as! Double
        highCelsius = aDecoder.decodeObject(forKey: "highCelsius") as! Double
        highFahrenheit = aDecoder.decodeObject(forKey: "highFahrenheit") as! Double
        lowFahrenheit = aDecoder.decodeObject(forKey: "lowFahrenheit") as! Double
        time = aDecoder.decodeObject(forKey: "time") as! Date
    }
}


extension Forecast {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(time, forKey: "time")
        aCoder.encode(weather, forKey: "weather")
        aCoder.encode(weather, forKey: "weather")
        aCoder.encode(icon, forKey: "icon")
        aCoder.encode(highCelsius, forKey: "highCelsius")
        aCoder.encode(lowCelsius, forKey: "lowCelsius")
        aCoder.encode(highFahrenheit, forKey: "highFahrenheit")
        aCoder.encode(lowFahrenheit, forKey: "lowFahrenheit")
    }
}
