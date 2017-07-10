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
    var hourForecast = [Hourly]()
    
    
    
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
        
        guard let latitude = ToDouble(from:json.findValue(path: locationAPI.latitude)) else {
            throw SerializationError.missing(locationAPI.latitude)
        }
        
        guard let longitude = ToDouble(from:json.findValue(path: locationAPI.longitude)) else {
            throw SerializationError.missing(locationAPI.longitude)
        }
        
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
}

extension Array where Element: Location {
    mutating func append(location newElement: Element) -> Element {
        for location in self {
            if location.city == newElement.city, location.countryCode == newElement.countryCode, location.latitude == newElement.latitude, location.longitude == newElement.longitude {
                return location
            }
        }
        
        self.append(newElement)
        return self.last!
    }
    
    func get(by request: DataManager.Request) -> Element? {
        let (format, params) = (request.1, request.2)
        
        for elem in self {
            if format == .city && elem.city == params[.city] && elem.country == params[.country] {
                return elem
            } else if format == .coordinates && elem.longitude == ToDouble(from: params[.longitude]) && elem.latitude == ToDouble(from: params[.latitude]) {
                return elem
            }
        }
        
        return nil
    }
}
