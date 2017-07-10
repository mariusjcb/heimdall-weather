//
//  WeatherDataManager.swift
//  Heimdall
//
//  Created by Marius Ilie on 08/07/2017.
//  Copyright © 2017 Marius Ilie. All rights reserved.
//

import Foundation

enum WeatherError: Error {
    case locationNotFound
    case tooSoonUpdate
    case cathed(String)
    case missing(String)
    case message(String, String)
    case unknown
}

protocol WeatherDataManagerDelegate {
    func weatherDataWill(request: DataManager.Request)
    func weatherDidChange(for location: Location, request: DataManager.Request)
    func didReceiveWeatherFetchingError(request: DataManager.Request, error: WeatherError?)
}

/**
 Manager pentru toate apelurile catre API, va serializa datele din JSON in array de Modele (obiecte Model din MVC) sau invers.
 Specific arhitecturii MVVM, functioneaza ca un Singleton.
 
 
 Responsabilitati:
 =================
 - Apelarea API-ului
 - Parsarea datelor din JSON
 - Serializarea datelor
 
 
 Implementare:
 =============
 ```
 DataManager.sharedInstance.anyProperty = value
 DataManager.sharedInstance.anyMethod()
 
 ```
 */

final class WeatherDataManager: DataManager {
    typealias WeatherDataCompletion = DataManager.DataCompletion
    
    class var shared: WeatherDataManager
    {
        struct Singleton
        {
            internal static let instance = WeatherDataManager(URLString: Defaults.RestAPI.AuthenticatedURLString)
        }
        
        return Singleton.instance
    }
    
    var delegate = [WeatherDataManagerDelegate]()
    
    // NSPointerArray.weakObjects()
    var locations = [Location]()
    weak var currentLocation: Location?
    
    private var _apiURL: URL?
    var apiURL: URL? { return _apiURL }
    
    //MARK: - Initlizer
    private init(URLString url: String?)
    {
        if let URLStringUnwrapped = url
        {
            self._apiURL = URL(string: URLStringUnwrapped)
            if _apiURL == nil {
                printError(NSLocalizedString("Invalid URL:", comment: "") + " " +  String(describing: URLStringUnwrapped))
            }
        } else { printError(NSLocalizedString("API URL is nil", comment: "")) }
    }
    
    //MARK: - RestAPI Usage
    private func query(for params: DataManager.RequestParams, by format: Defaults.RestAPI.QueryFormat = .coordinates,
                       as endpoint: Defaults.RestAPI.EndPoints = .conditions) -> String {
        var endpointFormat = Defaults.RestAPI.URL.endpointFormat.rawValue
        
        var queryFormat = format.rawValue
        for (key, value) in params {
            guard queryFormat.contains(key.rawValue) else {
                printError(NSLocalizedString("Path has no dynamic variable named ", comment: "") + " " +  key.rawValue)
                continue
            }
            
            queryFormat.replace(variable: key.rawValue, with: value)
        }
        
        endpointFormat.replace(variable: Defaults.RestAPI.DynamicVariables.endpoint.rawValue, with: endpoint.rawValue)
        endpointFormat.replace(variable: Defaults.RestAPI.DynamicVariables.query.rawValue, with: queryFormat)
        
        return endpointFormat
    }
    
    func weatherData(for params: DataManager.RequestParams, by format: Defaults.RestAPI.QueryFormat = .coordinates,
                        as endpoint: Defaults.RestAPI.EndPoints = .conditions, handler: WeatherDataCompletion? = nil)
    {
        if Defaults.RestAPI.forecasts.contains(endpoint) {
            guard let location = locations.get(by: (endpoint, format, params)) else {
                printError(NSLocalizedString("Forecast Update: Location not found in WeatherDataManager", comment: ""))
                
                WeatherDataManager.shared.delegate.forEach({ (eachDelegate) in
                    DispatchQueue.main.async {
                        eachDelegate.didReceiveWeatherFetchingError(request: (endpoint, format, params), error: .tooSoonUpdate)
                    }
                })
                return
            }
            
            let lastUpdate = Int(location.lastForecastsUpdate?.timeIntervalSinceNow ?? TimeInterval(0))  / 3600
            
            guard lastUpdate <= Defaults.bigUpdatesInterval else {
                printError(NSLocalizedString("Time from last all weather data update is too soon", comment: "") + " @ \(location.city), \(location.country)")
                
                WeatherDataManager.shared.delegate.forEach({ (eachDelegate) in
                    DispatchQueue.main.async {
                        eachDelegate.didReceiveWeatherFetchingError(request: (endpoint, format, params), error: .tooSoonUpdate)
                    }
                })
                return
            }
        }
        
        let path = query(for: params, by: format, as: endpoint)
        
        guard let callURL = apiURL?.append(path) else
        {
            printError(NSLocalizedString("Invalid path:", comment: "") + " " +  String(describing: path))
            return
        }
        
        printLog(NSLocalizedString("URL called:", comment: "") + " " +  callURL.relativeString)
        
        WeatherDataManager.shared.delegate.forEach({ (eachDelegate) in
            DispatchQueue.main.async {
                eachDelegate.weatherDataWill(request: (endpoint, format, params))
            }
        })
        
        URLSession.shared.dataTask(with: callURL) { (data, response, error) in
            self.didFetch(data: data, response: response, request: (endpoint, format, params), error: error, handler: handler)
        }.resume()
    }
    
    func weatherData(forCity city: String, country: String, as endpoint: Defaults.RestAPI.EndPoints = .conditions, handler: WeatherDataCompletion? = nil)
    {
        let params: DataManager.RequestParams = [
            .country    :  country,
            .city       :  city
        ]
        
        weatherData(for: params, by: .city, as: endpoint, handler: handler)
    }
    
    func weatherData(forLatitude lat: Double, longitude long: Double, as endpoint: Defaults.RestAPI.EndPoints = .conditions, handler: WeatherDataCompletion? = nil)
    {
        let params: DataManager.RequestParams = [
            .latitude   :   String(describing: lat),
            .longitude  :   String(describing: long)
        ]
        
        weatherData(for: params, by: .coordinates, as: endpoint, handler: handler)
    }
    
    //MARK: - Quick call methods
    static func conditions(forLatitude lat: Double, longitude long: Double) {
        shared.weatherData(forLatitude: lat, longitude: long, as: .conditions, handler: WeatherDataManager.conditionAPIHandler)
    }
    
    static func hourly(forLatitude lat: Double, longitude long: Double) {
        shared.weatherData(forLatitude: lat, longitude: long, as: .hourly, handler: WeatherDataManager.hourlyAPIHandler)
    }
    
    static func forecast(forLatitude lat: Double, longitude long: Double) {
        shared.weatherData(forLatitude: lat, longitude: long, as: .forecast, handler: WeatherDataManager.hourlyAPIHandler)
    }
    
    static func conditions(forCity city: String, country: String) {
        shared.weatherData(forCity: city, country: country, as: .conditions, handler: WeatherDataManager.conditionAPIHandler)
    }
    
    static func hourly(forCity city: String, country: String) {
        shared.weatherData(forCity: city, country: country, as: .hourly, handler: WeatherDataManager.hourlyAPIHandler)
    }
    
    static func forecast(forCity city: String, country: String) {
        shared.weatherData(forCity: city, country: country, as: .forecast, handler: WeatherDataManager.hourlyAPIHandler)
    }
    
    static func weather(forLatitude lat: Double, longitude long: Double) {
        shared.weatherData(forLatitude: lat, longitude: long, as: .conditions) { (data, request, error) in
            do {
                let _ = try parse(condition: data, for: request, error: error)
                shared.weatherData(forLatitude: lat, longitude: long, as: .hourly) { (data, request, error) in
                    do {
                        let _ = try parse(hourly: data, for: request, error: error)
                        shared.weatherData(forLatitude: lat, longitude: long, as: .forecast) { (data, request, error) in
                            do {
                                let location = shared.locations.get(by: request)
                                location?.lastForecastsUpdate = Date()
                                
                                let _ = try parse(forecast: data, for: request, error: error) //mama ei de pyramid of doom ...
                            } catch {
                                errorHandler(with: error, request: request)
                            }
                        }
                    } catch {
                        errorHandler(with: error, request: request)
                    }
                }
            } catch {
                errorHandler(with: error, request: request)
            }
        }
    }
    
    //Unmanaged.passUnretained(obj).toOpaque()
    //MARK: - Fetch methods
    static func parse(condition response: Any?, for request: DataManager.Request, error: Error?) throws -> Condition? {
        if error != nil { return nil }
        
        let endpoint = request.0
        
        guard endpoint == .conditions else {
            printError(endpoint.rawValue + " " + NSLocalizedString("Is not a required endpoint by completion handler", comment: ""));
            return nil
        }
        
        let condition = try Condition(json: response!)
        
        WeatherDataManager.shared.delegate.forEach({ (eachDelegate) in
            DispatchQueue.main.async {
                eachDelegate.weatherDidChange(for: condition.location, request: request)
            }
        })
        
        return condition
    }
    
    static func parse(hourly response: Any?, for request: DataManager.Request, error: Error?) throws -> [Hourly]? {
        if error != nil { return nil }
        
        let endpoint = request.0
        
        guard endpoint == .hourly else {
            printError(endpoint.rawValue + " " + NSLocalizedString("Is not a required endpoint by completion handler", comment: ""));
            return nil
        }
        
        let hourlyConditions = try [Hourly](json: response!, request: request)
        if let location = hourlyConditions[0].location {
            location.hourForecast = hourlyConditions
            
            WeatherDataManager.shared.delegate.forEach({ (eachDelegate) in
                DispatchQueue.main.async {
                    eachDelegate.weatherDidChange(for: location, request: request)
                }
            })
        } else {
            WeatherDataManager.shared.delegate.forEach({ (eachDelegate) in
                DispatchQueue.main.async {
                    eachDelegate.didReceiveWeatherFetchingError(request: request, error: WeatherError.locationNotFound)
                }
            })
        }
        
        return hourlyConditions
    }
    
    static func parse(forecast response: Any?, for request: DataManager.Request, error: Error?) throws -> [Forecast]? {
        if error != nil { return nil }
        
        let endpoint = request.0
        
        guard endpoint == .forecast else {
            printError(endpoint.rawValue + " " + NSLocalizedString("Is not a required endpoint by completion handler", comment: ""));
            return nil
        }
        
        let forecastConditions = try [Forecast](json: response!, request: request)
        if let location = forecastConditions[0].location {
            location.forecast = forecastConditions
            
            WeatherDataManager.shared.delegate.forEach({ (eachDelegate) in
                DispatchQueue.main.async {
                    eachDelegate.weatherDidChange(for: location, request: request)
                }
            })
        } else {
            WeatherDataManager.shared.delegate.forEach({ (eachDelegate) in
                DispatchQueue.main.async {
                    eachDelegate.didReceiveWeatherFetchingError(request: request, error: WeatherError.locationNotFound)
                }
            })
        }
        
        return forecastConditions
    }
    
    //MARK: - Default CompletionHandlers
    static func errorHandler(with error: Error, request: DataManager.Request) {
        switch error {
        case .missing(let member) as SerializationError:
            printError(NSLocalizedString("Missing", comment: "") + " " + member)
            
            WeatherDataManager.shared.delegate.forEach({ (eachDelegate) in
                DispatchQueue.main.async {
                    eachDelegate.didReceiveWeatherFetchingError(request: request, error: WeatherError.missing(member))
                }
            })
            break
        case .message(let type, let description) as SerializationError:
            printError(description)
            
            WeatherDataManager.shared.delegate.forEach({ (eachDelegate) in
                DispatchQueue.main.async {
                    eachDelegate.didReceiveWeatherFetchingError(request: request, error: WeatherError.message(type, description))
                }
            })
            break
        default:
            printError(error.localizedDescription)
            
            WeatherDataManager.shared.delegate.forEach({ (eachDelegate) in
                DispatchQueue.main.async {
                    eachDelegate.didReceiveWeatherFetchingError(request: request, error: WeatherError.cathed(error.localizedDescription))
                }
            })
        }
    }
    
    static let conditionAPIHandler: DataManager.DataCompletion = { (response, request, error) in
        do {
            _ = try parse(condition: response, for: request, error: error)
        } catch {
            errorHandler(with: error, request: request)
        }
    }
    
    static let hourlyAPIHandler: DataManager.DataCompletion = { (response, request, error) in
        do {
            _ = try parse(hourly: response, for: request, error: error)
        } catch {
            errorHandler(with: error, request: request)
        }
    }
}

func += (left: inout [WeatherDataManagerDelegate], right: WeatherDataManagerDelegate) {
    left.append(right)
}
