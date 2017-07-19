//
//  Condition.swift
//  Heimdall
//
//  Created by Marius Ilie on 08/07/2017.
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

@objc class Condition: NSObject, JSONDecodable
{
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
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        uv = aDecoder.decodeObject(forKey: "uv") as! Double
        humidity = aDecoder.decodeObject(forKey: "humidity") as! String
        weather = aDecoder.decodeObject(forKey: "weather") as! String
        icon = aDecoder.decodeObject(forKey: "icon") as! String
        time = aDecoder.decodeObject(forKey: "time") as! Date
        celsius = aDecoder.decodeObject(forKey: "celsius") as! Double
        celsiusFeels = aDecoder.decodeObject(forKey: "celsiusFeels") as! Double
        fahrenheit = aDecoder.decodeObject(forKey: "fahrenheit") as! Double
        fahrenheitFeels = aDecoder.decodeObject(forKey: "fahrenheitFeels") as! Double
        todayPrecipitationPerInch = aDecoder.decodeObject(forKey: "todayPrecipitationPerInch") as! Double
        todayPrecipitationMetric = aDecoder.decodeObject(forKey: "todayPrecipitationMetric") as! Double
        todayPrecipitationPerHourInch = aDecoder.decodeObject(forKey: "todayPrecipitationPerHourInch") as! Double
        todayPrecipitationPerHourMetric = aDecoder.decodeObject(forKey: "todayPrecipitationPerHourMetric") as! Double
        windDirection = aDecoder.decodeObject(forKey: "windDirection") as! String
        windDegrees = aDecoder.decodeObject(forKey: "windDegrees") as! Double
        windMpH = aDecoder.decodeObject(forKey: "windMpH") as! Double
        windKpH = aDecoder.decodeObject(forKey: "windKpH") as! Double
        pressureInch = aDecoder.decodeObject(forKey: "pressureInch") as! Double
        pressureMetric = aDecoder.decodeObject(forKey: "pressureMetric") as! Double
    }
}


extension Condition {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(uv, forKey: "uv")
        aCoder.encode(humidity, forKey: "humidity")
        aCoder.encode(weather, forKey: "weather")
        aCoder.encode(icon, forKey: "icon")
        aCoder.encode(time, forKey: "time")
        aCoder.encode(celsius, forKey: "celsius")
        aCoder.encode(celsiusFeels, forKey: "celsiusFeels")
        aCoder.encode(fahrenheit, forKey: "fahrenheit")
        aCoder.encode(fahrenheitFeels, forKey: "fahrenheitFeels")
        aCoder.encode(todayPrecipitationPerInch, forKey: "todayPrecipitationPerInch")
        aCoder.encode(todayPrecipitationMetric, forKey: "todayPrecipitationMetric")
        aCoder.encode(todayPrecipitationPerHourInch, forKey: "todayPrecipitationPerHourInch")
        aCoder.encode(todayPrecipitationPerHourMetric, forKey: "todayPrecipitationPerHourMetric")
        aCoder.encode(windDirection, forKey: "windDirection")
        aCoder.encode(windDegrees, forKey: "windDegrees")
        aCoder.encode(windMpH, forKey: "windMpH")
        aCoder.encode(windKpH, forKey: "windKpH")
        aCoder.encode(pressureInch, forKey: "pressureInch")
        aCoder.encode(pressureMetric, forKey: "pressureMetric")
    }
}
