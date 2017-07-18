//
//  Location+Helper.swift
//  Heimdall
//
//  Created by Marius Ilie on 18/07/2017.
//  Copyright © 2017 Marius Ilie. All rights reserved.
//

import Foundation

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
