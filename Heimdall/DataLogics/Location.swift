//
//  Location.swift
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

@objc class Location: NSObject, JSONDecodable
{
    let city: String
    
    let country: String
    let countryCode: String
    
    let latitude: Double
    let longitude: Double
    let elevation: Double
    
    var timeOffset: String
    
    var condition: Condition? = nil
    var forecast = [Forecast]()
    var hourForecast = [Hourly]()
    
    var lastForecastsUpdate: Date? = nil
    
    
    
    
    //MARK: - Failable Initializer
    required init(json: Any) throws
    {
        let keyPaths = Defaults.RestAPI.EndPoints.keyPaths.self
        
        let locationAPI = Defaults.RestAPI.LocationAPI.self
        
        let conditionAPI = Defaults.RestAPI.ConditionAPI.self
        
        
        guard let mainJSON = json as? [String: Any] else {
            printError(NSLocalizedString("JSON can't be converted into a dictionary", comment: ""))
            throw SerializationError.missing(NSLocalizedString("Main JSON", comment: ""))
        }
        
        
        
        //MARK: Condition JSON
        guard let conditionJSON = mainJSON.locate(path: keyPaths[.conditions]!) else {
            printError(keyPaths[.conditions]! + " "
                + NSLocalizedString("JSON Key doesn't exist or can't be converted into dictionary object", comment: ""))
            
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
        
        guard let timeOffset = conditionJSON.findValue(path: conditionAPI.timeOffset) as? String else {
            throw SerializationError.missing(conditionAPI.timeOffset)
        }
        
        
        //MARK: Location JSON
        let locationKeyPath = Defaults.RestAPI.LocationAPI.keyPaths[.conditions]!
        guard let json = conditionJSON.locate(path: locationKeyPath) else {
            throw SerializationError.missing(locationKeyPath)
        }
        
        guard let city = json.findValue(path: locationAPI.city) as? String else {
            throw SerializationError.missing(locationAPI.city)
        }
        
        guard let country = json.findValue(path: locationAPI.country) as? String else {
            throw SerializationError.missing(locationAPI.country)
        }
        
        guard let countryCode = json.findValue(path: locationAPI.countryCode) as? String else {
            throw SerializationError.missing(locationAPI.countryCode)
        }
        
        guard var latitude = ToDouble(from:json.findValue(path: locationAPI.latitude)) else {
            throw SerializationError.missing(locationAPI.latitude)
        }
        latitude = round(latitude*100)/100
        
        guard var longitude = ToDouble(from:json.findValue(path: locationAPI.longitude)) else {
            throw SerializationError.missing(locationAPI.longitude)
        }
        longitude = round(longitude*100)/100
        
        guard let elevation = ToDouble(from:json.findValue(path: locationAPI.elevation)) else {
            throw SerializationError.missing(locationAPI.elevation)
        }
        
        
        
        self.city = city
        self.country = country
        self.countryCode = countryCode
        self.latitude = latitude
        self.longitude = longitude
        self.elevation = elevation
        
        self.timeOffset = timeOffset
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        city = aDecoder.decodeObject(forKey: "city") as! String
        country = aDecoder.decodeObject(forKey: "country") as! String
        countryCode = aDecoder.decodeObject(forKey: "countryCode") as! String
        latitude = aDecoder.decodeObject(forKey: "latitude") as! Double
        longitude = aDecoder.decodeObject(forKey: "longitude") as! Double
        elevation = aDecoder.decodeObject(forKey: "elevation") as! Double
        timeOffset = aDecoder.decodeObject(forKey: "timeOffset") as! String
        
        if let condData = aDecoder.decodeObject(forKey: "condition") as? Data {
            condition = NSKeyedUnarchiver.unarchiveObject(with: condData) as? Condition
        }
        
        forecast = NSKeyedUnarchiver.unarchiveObject(with:
            aDecoder.decodeObject(forKey: "forecast") as! Data) as! [Forecast]
        
        hourForecast = NSKeyedUnarchiver.unarchiveObject(with:
            aDecoder.decodeObject(forKey: "hourForecast") as! Data) as! [Hourly]
        
        lastForecastsUpdate = aDecoder.decodeObject(forKey: "lastForecastsUpdate") as? Date
    }
}


extension Location {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(city, forKey: "city")
        aCoder.encode(country, forKey: "country")
        aCoder.encode(countryCode, forKey: "countryCode")
        aCoder.encode(latitude, forKey: "latitude")
        aCoder.encode(longitude, forKey: "longitude")
        aCoder.encode(elevation, forKey: "elevation")
        aCoder.encode(timeOffset, forKey: "timeOffset")
        
        aCoder.encode(NSKeyedArchiver.archivedData(withRootObject: forecast),
                      forKey: "forecast")
        
        aCoder.encode(NSKeyedArchiver.archivedData(withRootObject: hourForecast),
                      forKey: "hourForecast")
        
        
        if condition != nil {
            aCoder.encode(NSKeyedArchiver.archivedData(withRootObject: condition!),
                          forKey: "condition")
        }
        
        if lastForecastsUpdate != nil {
            aCoder.encode(lastForecastsUpdate!, forKey: "lastForecastsUpdate")
        }
    }
}

protocol JSONDecodableWithLocation: NSCoding {
    init(json: Any, location: Location?) throws
}
