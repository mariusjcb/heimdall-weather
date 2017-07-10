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
    func conditions(forLatitude lat: Double, longitude long: Double) {
        weatherData(forLatitude: lat, longitude: long, as: .conditions, handler: WeatherDataManager.conditionAPIHandler)
    }
    
    func hourly(forLatitude lat: Double, longitude long: Double) {
        weatherData(forLatitude: lat, longitude: long, as: .hourly, handler: WeatherDataManager.hourlyAPIHandler)
    }
    
    func conditions(forCity city: String, country: String) {
        weatherData(forCity: city, country: country, as: .conditions, handler: WeatherDataManager.conditionAPIHandler)
    }
    
    func hourly(forCity city: String, country: String) {
        weatherData(forCity: city, country: country, as: .hourly, handler: WeatherDataManager.hourlyAPIHandler)
    }
    
    //Unmanaged.passUnretained(obj).toOpaque()
    //MARK: - Handlers
    static let conditionAPIHandler: DataManager.DataCompletion = { (response, request, error) in
        do {
            if error != nil { return }
            
            let endpoint = request.0
            
            guard endpoint == .conditions else {
                printError(endpoint.rawValue + " " + NSLocalizedString("Is not a required endpoint by completion handler", comment: ""));
                return
            }
            
            let condition = try Condition(json: response!)
            
            WeatherDataManager.shared.delegate.forEach({ (eachDelegate) in
                DispatchQueue.main.async {
                    eachDelegate.weatherDidChange(for: condition.location, request: request)
                }
            })
        } catch SerializationError.missing(let member) {
            printError(NSLocalizedString("Missing", comment: "") + " " + member)
            
            WeatherDataManager.shared.delegate.forEach({ (eachDelegate) in
                DispatchQueue.main.async {
                    eachDelegate.didReceiveWeatherFetchingError(request: request, error: WeatherError.missing(member))
                }
            })
        } catch SerializationError.message(let type, let description) {
            printError(description)
            
            WeatherDataManager.shared.delegate.forEach({ (eachDelegate) in
                DispatchQueue.main.async {
                    eachDelegate.didReceiveWeatherFetchingError(request: request, error: WeatherError.message(type, description))
                }
            })
        } catch {
            printError(error.localizedDescription)
            
            WeatherDataManager.shared.delegate.forEach({ (eachDelegate) in
                DispatchQueue.main.async {
                    eachDelegate.didReceiveWeatherFetchingError(request: request, error: WeatherError.cathed(error.localizedDescription))
                }
            })
        }
    }
    
    static let hourlyAPIHandler: DataManager.DataCompletion = { (response, request, error) in
        do {
            if error != nil { return }
            
            let endpoint = request.0
            
            guard endpoint == .hourly else {
                printError(endpoint.rawValue + " " + NSLocalizedString("Is not a required endpoint by completion handler", comment: ""));
                return
            }
            
            let hourlyConditions = try [Hourly](json: response!)
            let loc = WeatherDataManager.shared.locations.get(by: request)
            
            if let location = loc {
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
        } catch SerializationError.missing(let member) {
            printError(NSLocalizedString("Missing", comment: "") + " " + member)
            
            WeatherDataManager.shared.delegate.forEach({ (eachDelegate) in
                DispatchQueue.main.async {
                    eachDelegate.didReceiveWeatherFetchingError(request: request, error: WeatherError.missing(member))
                }
            })
        } catch SerializationError.message(let type, let description) {
            printError(description)
            
            WeatherDataManager.shared.delegate.forEach({ (eachDelegate) in
                DispatchQueue.main.async {
                    eachDelegate.didReceiveWeatherFetchingError(request: request, error: WeatherError.message(type, description))
                }
            })
        } catch {
            printError(error.localizedDescription)
            
            WeatherDataManager.shared.delegate.forEach({ (eachDelegate) in
                DispatchQueue.main.async {
                    eachDelegate.didReceiveWeatherFetchingError(request: request, error: WeatherError.cathed(error.localizedDescription))
                }
            })
        }
    }
}

func += (left: inout [WeatherDataManagerDelegate], right: WeatherDataManagerDelegate) {
    left.append(right)
}
