//
//  Location.swift
//  Heimdall
//
//  Created by Marius Ilie on 08/07/2017.
//  Copyright © 2017 Marius Ilie. All rights reserved.
//

import Foundation

class Location: JSONDecodable
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
    required init(json: Any) throws {
        let locationAPI = Defaults.RestAPI.LocationAPI.self
        
        guard let json = json as? [String: Any] else {
            printError(NSLocalizedString("JSON can't be converted into a dictionary", comment: ""))
            throw SerializationError.missing(NSLocalizedString("Main JSON", comment: ""))
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
        
        self.timeOffset = String(describing: TimeZone.current.secondsFromGMT())
    }
    
    required init?(coder aDecoder: NSCoder) {
        city = aDecoder.decodeObject(forKey: "city") as! String
        country = aDecoder.decodeObject(forKey: "country") as! String
        countryCode = aDecoder.decodeObject(forKey: "countryCode") as! String
        latitude = aDecoder.decodeObject(forKey: "latitude") as! Double
        longitude = aDecoder.decodeObject(forKey: "longitude") as! Double
        elevation = aDecoder.decodeObject(forKey: "elevation") as! Double
        timeOffset = aDecoder.decodeObject(forKey: "timeOffset") as! String
        condition = aDecoder.decodeObject(forKey: "condition") as? Condition
        forecast = aDecoder.decodeObject(forKey: "forecast") as! [Forecast]
        hourForecast = aDecoder.decodeObject(forKey: "hourForecast") as! [Hourly]
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
        aCoder.encode(condition, forKey: "condition")
        aCoder.encode(forecast, forKey: "forecast")
        aCoder.encode(hourForecast, forKey: "hourForecast")
        aCoder.encode(lastForecastsUpdate, forKey: "lastForecastsUpdate")
    }
}


extension Array where Element: Location {
    mutating func append(location newElement: Element) -> Element {
        for location in self {
            if location.city == newElement.city, location.countryCode == newElement.countryCode,
               location.latitude == newElement.latitude,
               location.longitude == newElement.longitude {
                return location
            }
        }
        
        self.append(newElement)
        return newElement
    }
    
    func get(by request: DataManager.APIRequest) -> Location? {
        let (format, params) = (request.1, request.2)
        if format == .coordinates { print(print(round(ToDouble(from: params[.latitude]!)!))) }
        
        var elem: Element? = nil
        self.forEach {
            if format == .city && $0.city == params[.city] && $0.countryCode == params[.country] {
                elem = $0
            } else if format == .coordinates && $0.longitude == round(ToDouble(from: params[.longitude]!)!*100)/100
                && $0.latitude == round(ToDouble(from: params[.latitude]!)!*100)/100 {
                elem = $0
            }
        }
        
        return elem
    }
}

func ==(lhs: Location, rhs: Location) -> Bool {
    return lhs.city == rhs.city && lhs.countryCode == rhs.countryCode
}

protocol JSONDecodableWithLocation: NSCoding {
    init(json: Any, location: Location?) throws
}
