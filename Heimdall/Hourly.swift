//
//  Hourly.swift
//  Heimdall
//
//  Created by Marius Ilie on 09/07/2017.
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

@objc class Hourly: NSObject, JSONDecodableWithLocation
{
    //weak var location: Location?
    var time: Date
    
    let humidity: Double
    let weather: String
    let icon: String
    
    let celsius: Double
    let celsiusFeels: Double
    
    let fahrenheit: Double
    let fahrenheitFeels: Double
    
    let windDirection: String
    let windDegrees: Double
    
    
    
    
    //MARK: - Failable Initializer
    required init(json: Any, location: Location?) throws {
        let hourlyAPI = Defaults.RestAPI.HourlyAPI.self
        
        guard let json = json as? [String: Any] else {
            printError(NSLocalizedString("JSON can't be converted into a dictionary", comment: ""))
            throw SerializationError.missing(NSLocalizedString("Main JSON", comment: ""))
        }
        
        guard let hour = json.findValue(path: hourlyAPI.hour) as? String else {
            throw SerializationError.missing(hourlyAPI.hour)
        }
        
        guard let minutes = json.findValue(path: hourlyAPI.minutes) as? String else {
            throw SerializationError.missing(hourlyAPI.minutes)
        }
        
        guard let day = json.findValue(path: hourlyAPI.day) as? String else {
            throw SerializationError.missing(hourlyAPI.day)
        }
        
        guard let month = json.findValue(path: hourlyAPI.month) as? String else {
            throw SerializationError.missing(hourlyAPI.month)
        }
        
        guard let year = json.findValue(path: hourlyAPI.year) as? String else {
            throw SerializationError.missing(hourlyAPI.year)
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
        
        self.time = Date(hour, minutes, year, month, day, location?.timeOffset ?? String(describing: TimeZone.current.secondsFromGMT()))
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        icon = aDecoder.decodeObject(forKey: "icon") as! String
        windDirection = aDecoder.decodeObject(forKey: "windDirection") as! String
        humidity = aDecoder.decodeObject(forKey: "humidity") as! Double
        celsius = aDecoder.decodeObject(forKey: "celsius") as! Double
        celsiusFeels = aDecoder.decodeObject(forKey: "celsiusFeels") as! Double
        weather = aDecoder.decodeObject(forKey: "weather") as! String
        fahrenheit = aDecoder.decodeObject(forKey: "fahrenheit") as! Double
        fahrenheitFeels = aDecoder.decodeObject(forKey: "fahrenheitFeels") as! Double
        windDegrees = aDecoder.decodeObject(forKey: "windDegrees") as! Double
        time = aDecoder.decodeObject(forKey: "time") as! Date
    }
}


extension Hourly {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(time, forKey: "time")
        aCoder.encode(humidity, forKey: "humidity")
        aCoder.encode(weather, forKey: "weather")
        aCoder.encode(icon, forKey: "icon")
        aCoder.encode(celsius, forKey: "celsius")
        aCoder.encode(celsiusFeels, forKey: "celsiusFeels")
        aCoder.encode(fahrenheit, forKey: "fahrenheit")
        aCoder.encode(fahrenheitFeels, forKey: "fahrenheitFeels")
        aCoder.encode(windDirection, forKey: "windDirection")
        aCoder.encode(windDegrees, forKey: "windDegrees")
    }
}
