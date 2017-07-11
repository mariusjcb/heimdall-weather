//
//  Hourly.swift
//  Heimdall
//
//  Created by Marius Ilie on 09/07/2017.
//  Copyright © 2017 Marius Ilie. All rights reserved.
//

import Foundation

class Hourly: JSONDecodableByRequest
{
    weak var location: Location?
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
    private init(json: Any) throws {
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
        self.location = nil
    }
    
    required convenience init(json: Any, request: DataManager.APIRequest) throws {
        try self.init(json: json)
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
        
        guard let location = WeatherDataManager.shared.locations.get(by: request) else {
            throw SerializationError.message(
                NSLocalizedString("Runtime Exception", comment: ""),
                NSLocalizedString("Requested location not exist into WeatherDataManager, call condition API first.", comment: "")
            )
        }
        
        self.location = location
        self.time = Date(hour, minutes, year, month, day, self.location?.timeOffset ?? String(describing: TimeZone.current.secondsFromGMT()))
    }
    
    required init?(coder aDecoder: NSCoder) {
        WeatherDataManager.shared.locations.append(aDecoder.decodeObject(forKey: "location") as! Location)
        self.location = aDecoder.decodeObject(forKey: "location") as? Location
        
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
        aCoder.encode(location, forKey: "location")
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

extension Array where Element: Hourly {
    init(json: Any, request: DataManager.APIRequest) throws {
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
            let condition = try Hourly(json: hourlyJSON, request: request)
            
            if let element = condition as? Element {
                self.append(element)
            }
        }
    }
}
