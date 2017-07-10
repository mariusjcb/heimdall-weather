//
//  Defaults.swift
//  Heimdall
//
//  Created by Marius Ilie on 08/07/2017.
//  Copyright © 2017 Marius Ilie. All rights reserved.
//

import Foundation

extension Defaults.RestAPI
{
    static let keySettingsProperty      =   "API Key"
    
    enum DynamicVariables: String {
        case baseurl                    =   "BASE_URL"
        case key                        =   "API_KEY"
        case endpoint                   =   "ENDPOINT"
        case query                      =   "QUERY"
        case country                    =   "COUNTRY"
        case city                       =   "CITY"
        case latitude                   =   "LAT"
        case longitude                  =   "LONG"
    }
    
    enum URL: String {
        case baseURL                    =   "http://api.wunderground.com/api"
        case authenticatedURLFormat     =   "{BASE_URL}/{API_KEY}"
        case endpointFormat             =   "/{ENDPOINT}/q/{QUERY}"
    }
    
    enum QueryFormat: String {
        case city                       =   "/{COUNTRY}/{CITY}.json"
        case coordinates                =   "/{LAT},{LONG}.json"
    }
    
    enum EndPoints: String {
        case error                      =   "error"
        case conditions                 =   "conditions"
        case hourly                     =   "hourly"
        case forecast10day              =   "forecast10day"
        
        static let keyPaths: Dictionary<EndPoints, String> = [
            .error                      :   "response => error",
            .conditions                 :   "current_observation",
            .hourly                     :   "hourly_forecast",
            .forecast10day              :   "forecast => simpleforecast"
        ]
    }
    
    struct ErrorAPI {
        static let type                 =   "type"
        static let description          =   "description"
    }
    
    struct LocationAPI {
        static let keyPaths: Dictionary<EndPoints, String> =   [
            .conditions                 :   "display_location"
        ]
        
        static let city                 =   "city"
        static let country              =   "state_name"
        static let countryCode          =   "country"
        static let latitude             =   "latitude"
        static let longitude            =   "longitude"
        static let elevation            =   "elevation"
    }
    
    struct ConditionAPI {
        static let uv                   =   "UV"
        static let humidity             =   "relative_humidity"
        static let weather              =   "weather"
        static let icon                 =   "icon"
        static let celsiusTemp          =   "temp_c"
        static let fahrenheitTemp       =   "temp_f"
        static let celsiusFeels         =   "feelslike_c"
        static let fahrenheitFeels      =   "feelslike_f"
        static let todayPrecipIn        =   "precip_today_in"
        static let todayPrecipMetric    =   "precip_today_metric"
        static let hourPrecipPerInch    =   "precip_1hr_in"
        static let hourPrecipMetric     =   "precip_1hr_metric"
        static let windDirection        =   "wind_dir"
        static let windDegrees          =   "wind_degrees"
        static let windMpH              =   "wind_mph"
        static let windKpH              =   "wind_kph"
        static let pressureInch         =   "pressure_in"
        static let pressureMetric       =   "pressure_mb"
        static let timeOffset           =   "local_tz_offset"
    }
    
    struct HourlyAPI {
        static let humidity             =   "humidity"
        static let weather              =   "condition"
        static let icon                 =   "icon"
        static let celsiusTemp          =   "temp => metric"
        static let fahrenheitTemp       =   "temp => english"
        static let celsiusFeels         =   "feelslike => metric"
        static let fahrenheitFeels      =   "feelslike => english"
        static let windDirection        =   "wdir => dir"
        static let windDegrees          =   "wdir => degrees"
        static let hour                 =   "FCTTIME => hour_padded"
        static let minutes              =   "FCTTIME => min"
        static let year                 =   "FCTTIME => year"
        static let month                =   "FCTTIME => mon_padded"
        static let day                  =   "FCTTIME => mday_padded"
    }
    
    struct Forecast10DayAPI {
        static let humidity             =   "humidity"
        static let weather              =   "condition"
        static let icon                 =   "icon"
        static let celsiusTemp          =   "temp => metric"
        static let fahrenheitTemp       =   "temp => english"
        static let celsiusFeels         =   "feelslike => metric"
        static let fahrenheitFeels      =   "feelslike => english"
        static let windDirection        =   "wdir => dir"
        static let windDegrees          =   "wdir => degrees"
    }
}
