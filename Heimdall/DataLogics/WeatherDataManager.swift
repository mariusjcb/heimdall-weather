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
    func weatherDataWill(request: DataManager.APIRequest)
    func weatherDidChange(for location: Location, request: DataManager.APIRequest)
    func didReceiveWeatherFetchingError(request: DataManager.APIRequest, error: WeatherError?)
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
 WeatherDataManager.shared.anyProperty = value
 WeatherDataManager.shared.anyMethod()
 
 ```
 */

class WeatherDataManager: DataManager, LocationManagerDelegate {
    typealias WeatherDataCompletion = DataManager.APIDataCompletion
    typealias TrackedLocation = Dictionary<String, Double>
    
    class var shared: WeatherDataManager
    {
        struct Singleton
        {
            internal static let instance = WeatherDataManager(URLString: Defaults.RestAPI.AuthenticatedURLString)
        }
        
        return Singleton.instance
    }
    
    var delegates = MulticastDelegate<WeatherDataManagerDelegate>()
    
    final var locations = [Location]()
    final weak var currentLocation: Location?
    var tracked = [TrackedLocation]() {
        didSet {
            UserDefaults.init(suiteName: Defaults.suiteName)?.set(tracked, forKey: Defaults.trackedUDName)
        }
    }
    
    private var _apiURL: URL?
    var apiURL: URL? { return _apiURL }
    
    
    
    //MARK: - Initlizer
    
    private init(URLString url: String?)
    {
        super.init()
        
        if let URLStringUnwrapped = url
        {
            self._apiURL = URL(string: URLStringUnwrapped)
            if _apiURL == nil {
                printError(NSLocalizedString("Invalid URL:", comment: "") + " " +  String(describing: URLStringUnwrapped))
            }
        } else { printError(NSLocalizedString("API URL is nil", comment: "")) }
    }
    
    
    
    //MARK: - Load functions
    
    func loadData() {
        loadCurrentLocationWeather()
        loadTrackedLocations()
    }
    
    func loadTrackedLocations() {
        if let loaded = UserDefaults.init(suiteName: Defaults.suiteName)?.object(forKey: Defaults.trackedUDName) as? [TrackedLocation] {
            tracked = loaded
            
            let dynvar = Defaults.RestAPI.DynamicVariables.self
            for loc in tracked {
                WeatherDataManager.weather(forLatitude: loc[dynvar.latitude.rawValue]!, longitude: loc[dynvar.longitude.rawValue]!)
            }
        }
    }
    
    func loadCurrentLocationWeather() {
        LocationManager.shared.delegates.add(self)
        LocationManager.shared.startMonitoringSignificantLocationChanges()
    }
    
    
    
    //MARK: - Data
    
    func track(latitude: Double, longitude: Double) {
        let dynvar = Defaults.RestAPI.DynamicVariables.self
        
        let toTrack = [
            dynvar.latitude.rawValue: round(latitude*100)/100,
            dynvar.longitude.rawValue: round(longitude*100)/100
        ]
        
        guard tracked.contains(where: { $0 == toTrack }) == false else { return }
        tracked.append(toTrack)
    }
    
    func untrack(latitude: Double, longitude: Double) {
        let dynvar = Defaults.RestAPI.DynamicVariables.self
        
        let toTrack = [
            dynvar.latitude.rawValue: round(latitude*100)/100,
            dynvar.longitude.rawValue: round(longitude*100)/100
        ]
        
        guard let index = tracked.index(where: { $0 == toTrack }) else { return }
        tracked.remove(at: index)
    }
    
    
    
    //MARK: - RestAPI Usage
    
    private func query(for params: DataManager.APIRequestParams, by format: Defaults.RestAPI.QueryFormat = .coordinates,
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
        
        let lang = Locale.current.identifier.uppercased()
        endpointFormat.replace(variable: Defaults.RestAPI.DynamicVariables.language.rawValue, with: lang)
        
        guard let endpointFormatURL = endpointFormat.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            return endpointFormat
        }
        
        return endpointFormatURL
    }
    
    func weatherData(for params: DataManager.APIRequestParams, by format: Defaults.RestAPI.QueryFormat = .coordinates,
                        as endpoint: Defaults.RestAPI.EndPoints = .conditions, handler: WeatherDataCompletion? = nil)
    {
        if Defaults.RestAPI.forecasts.contains(endpoint) {
            guard let location = locations.get(by: (endpoint, format, params)) else {
                printError(NSLocalizedString("Forecast Update: Location not found in WeatherDataManager", comment: ""))
                
                delegates.invoke { (delegate) in
                    DispatchQueue.main.async {
                        delegate.didReceiveWeatherFetchingError(request: (endpoint, format, params), error: .tooSoonUpdate)
                    }
                }
                return
            }
            
            let lastUpdate = Int(location.lastForecastsUpdate?.timeIntervalSinceNow ?? TimeInterval(0))  / 3600
            
            guard lastUpdate <= Defaults.bigUpdatesInterval else {
                printError(NSLocalizedString("Time from last all weather data update is too soon", comment: "") + " @ \(location.city), \(location.country)")
                
                delegates.invoke { (delegate) in
                    DispatchQueue.main.async {
                        delegate.didReceiveWeatherFetchingError(request: (endpoint, format, params), error: .tooSoonUpdate)
                    }
                }
                return
            }
        }
        
        let path = query(for: params, by: format, as: endpoint)
        
        guard let callURL = apiURL?.append(path) else {
            printError(NSLocalizedString("Invalid path:", comment: "") + " " +  String(describing: path))
            return
        }
        
        printLog(NSLocalizedString("URL called:", comment: "") + " " +  callURL.relativeString)
        
        delegates.invoke { (delegate) in
            DispatchQueue.main.async {
                delegate.weatherDataWill(request: (endpoint, format, params))
            }
        }
        
        URLSession.shared.dataTask(with: callURL) { [weak self] (data, response, error) in
            self?.didFetch(data: data, response: response, request: (endpoint, format, params), error: error) { [weak self]
                (json, request, error) in
                
                guard error == nil else {
                    self?.delegates.invoke { (delegate) in
                        DispatchQueue.main.async {
                            delegate.didReceiveWeatherFetchingError(
                                request: (endpoint, format, params),
                                error: .message(
                                    NSLocalizedString("Runtime Exception", comment: ""),
                                    error?.localizedDescription ?? NSLocalizedString("Unknown Error", comment: "")
                                )
                            )
                        }
                    }
                    return
                }
                
                if let handler = handler {
                    handler(json, request, error)
                }
            }
        }.resume()
    }
    
    func weatherData(forCity city: String, country: String, as endpoint: Defaults.RestAPI.EndPoints = .conditions, handler: WeatherDataCompletion? = nil)
    {
        let params: DataManager.APIRequestParams = [
            .country    :  country,
            .city       :  city
        ]
        
        weatherData(for: params, by: .city, as: endpoint, handler: handler)
    }
    
    func weatherData(forLatitude lat: Double, longitude long: Double, as endpoint: Defaults.RestAPI.EndPoints = .conditions, handler: WeatherDataCompletion? = nil)
    {
        let params: DataManager.APIRequestParams = [
            .latitude   :   String(describing:lat),
            .longitude  :   String(describing:long)
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
    
    static func weather(forLatitude lat: Double, longitude long: Double) {
        shared.weatherData(forLatitude: lat, longitude: long, as: .conditions) { (data, request, error) in
            do {
                let _ = try parse(condition: data, for: request, error: error)
                forecasts(request: request)
            } catch {
                errorHandler(with: error, request: request)
            }
        }
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
    
    static func weather(forCity city: String, country: String) {
        shared.weatherData(forCity: city, country: country, as: .conditions) { (data, request, error) in
            do {
                let _ = try parse(condition: data, for: request, error: error)
                forecasts(request: request)
            } catch {
                errorHandler(with: error, request: request)
            }
        }
    }
    
    static func forecasts(request: DataManager.APIRequest) {
        shared.weatherData(for: request.2, by: request.1, as: .hourly) { (data, request, error) in
            do {
                let _ = try parse(hourly: data, for: request, error: error)
            } catch {
                errorHandler(with: error, request: request)
            }
        }
        
        shared.weatherData(for: request.2, by: request.1, as: .forecast) { (data, request, error) in
            do {
                let location = shared.locations.get(by: request)
                location?.lastForecastsUpdate = Date()
                
                let _ = try parse(forecast: data, for: request, error: error)
            } catch {
                errorHandler(with: error, request: request)
            }
        }
    }
    
    
    
    //MARK: - Fetch methods
    
    static func parse(condition response: Any?, for request: DataManager.APIRequest, error: Error?) throws -> Location? {
        if error != nil { return nil }
        
        let endpoint = request.0
        
        guard endpoint == .conditions else {
            printError(endpoint.rawValue + " " + NSLocalizedString("Is not a required endpoint by completion handler", comment: ""));
            
            shared.delegates.invoke { (delegate) in
                DispatchQueue.main.async {
                    delegate.didReceiveWeatherFetchingError(request: request, error: WeatherError.missing("endpoint"))
                }
            }
            
            return nil
        }
        
        //MARK: Parse location from condition json
        let location = WeatherDataManager.shared.locations.append(location: try Location(json: response!))
        location.condition = try Condition(json: response!)
        
        
        if location.longitude == LocationManager.shared.longitude,
            location.latitude == LocationManager.shared.latitude {
            WeatherDataManager.shared.currentLocation = location
            shared.updateWidget()
        } else {
            WeatherDataManager.shared.track(latitude: location.latitude, longitude: location.longitude)
        }
        
        
        shared.delegates.invoke { (delegate) in
            DispatchQueue.main.async {
                delegate.weatherDidChange(for: location, request: request)
            }
        }
        
        
        return location
    }
    
    static func parse(hourly response: Any?, for request: DataManager.APIRequest, error: Error?) throws -> [Hourly]? {
        if error != nil { return nil }
        
        let endpoint = request.0
        
        guard endpoint == .hourly else {
            printError(endpoint.rawValue + " " + NSLocalizedString("Is not a required endpoint by completion handler", comment: ""));
            
            shared.delegates.invoke { (delegate) in
                DispatchQueue.main.async {
                    delegate.didReceiveWeatherFetchingError(request: request, error: WeatherError.missing("endpoint"))
                }
            }
            
            return nil
        }
        
        guard let location = shared.locations.get(by: request) else {
            shared.delegates.invoke { (delegate) in
                DispatchQueue.main.async {
                    delegate.didReceiveWeatherFetchingError(request: request, error: WeatherError.locationNotFound)
                }
            }
            
            return nil
        }
        
        let hourlyConditions = try [Hourly](json: response!, location: location)
        
        location.hourForecast = hourlyConditions
        
        shared.delegates.invoke { (delegate) in
            DispatchQueue.main.async {
                delegate.weatherDidChange(for: location, request: request)
            }
        }
        
        return hourlyConditions
    }
    
    static func parse(forecast response: Any?, for request: DataManager.APIRequest, error: Error?) throws -> [Forecast]? {
        if error != nil { return nil }
        
        let endpoint = request.0
        
        guard endpoint == .forecast else {
            printError(endpoint.rawValue + " " + NSLocalizedString("Is not a required endpoint by completion handler", comment: ""));
            return nil
        }
        
        guard let location = shared.locations.get(by: request) else {
            shared.delegates.invoke { (delegate) in
                DispatchQueue.main.async {
                    delegate.didReceiveWeatherFetchingError(request: request, error: WeatherError.locationNotFound)
                }
            }
            
            return nil
        }
        
        let forecastConditions = try [Forecast](json: response!, location: location)
        
        location.forecast = forecastConditions
        
        shared.delegates.invoke { (delegate) in
            DispatchQueue.main.async {
                delegate.weatherDidChange(for: location, request: request)
            }
        }
        
        return forecastConditions
    }
    
    
    
    //MARK: - Default CompletionHandlers
    
    static func errorHandler(with error: Error, request: DataManager.APIRequest) {
        switch error {
        case .missing(let member) as SerializationError:
            printError(NSLocalizedString("Missing", comment: "") + " " + member)
            
            shared.delegates.invoke { (delegate) in
                DispatchQueue.main.async {
                    delegate.didReceiveWeatherFetchingError(request: request, error: WeatherError.missing(member))
                }
            }
            break
        case .message(let type, let description) as SerializationError:
            printError(description)
            
            shared.delegates.invoke { (delegate) in
                DispatchQueue.main.async {
                    delegate.didReceiveWeatherFetchingError(request: request, error: WeatherError.message(type, description))
                }
            }
            break
        default:
            printError(error.localizedDescription)
            
            shared.delegates.invoke { (delegate) in
                DispatchQueue.main.async {
                    delegate.didReceiveWeatherFetchingError(request: request, error: WeatherError.cathed(error.localizedDescription))
                }
            }
        }
    }
    
    static let conditionAPIHandler: DataManager.APIDataCompletion = { (response, request, error) in
        do {
            _ = try parse(condition: response, for: request, error: error)
        } catch {
            errorHandler(with: error, request: request)
        }
    }
    
    static let hourlyAPIHandler: DataManager.APIDataCompletion = { (response, request, error) in
        do {
            _ = try parse(hourly: response, for: request, error: error)
        } catch {
            errorHandler(with: error, request: request)
        }
    }
    
    
    
    //MARK: - LocationManagerDelegate

    func locationDidChange(latitude: Double, longitude: Double) {
        WeatherDataManager.weather(forLatitude: latitude, longitude: longitude)
    }
    
    
    
    //MARK: - Today Extension
    
    func updateWidget() {
        UserDefaults.init(suiteName: Defaults.suiteName)?.set(currentLocation?.city, forKey: Defaults.widget.city)
        UserDefaults.init(suiteName: Defaults.suiteName)?.set(currentLocation?.condition?.celsius, forKey: Defaults.widget.temperature)
        UserDefaults.init(suiteName: Defaults.suiteName)?.set(currentLocation?.condition?.weather, forKey: Defaults.widget.condition)
        UserDefaults.init(suiteName: Defaults.suiteName)?.set(currentLocation?.condition?.icon, forKey: Defaults.widget.icon)
    }
}
