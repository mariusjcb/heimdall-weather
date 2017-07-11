//
//  PageViewController.swift
//  Heimdall
//
//  Created by Marius Ilie on 11/07/2017.
//  Copyright © 2017 Marius Ilie. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController, WeatherDataManagerDelegate {
    var vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LocationVC1") as! ViewController
    
    override func viewDidLoad() {
        
        self.dataSource = self as? UIPageViewControllerDataSource
        self.delegate = self as? UIPageViewControllerDelegate
        
        setViewControllers([vc],
                           direction: .forward,
                           animated: true,
                           completion: nil)
        
        WeatherDataManager.shared.delegates.add(self)
        
        _ = LocationManager.shared
        LocationManager.shared.startMonitoringSignificantLocationChanges()
    }
    
    //MARK: WeatherDataManagerDelegate
    
    func weatherDataWill(request: DataManager.APIRequest) {
        print("Will request...")
    }
    
    func weatherDidChange(for location: Location, request: DataManager.APIRequest) {
        for vc in viewControllers! {
            let vc = vc as! ViewController
            var ok = false
            
            if location.city == vc.params[.city] && location.country == vc.params[.country] {
                ok = true
            } else if location.longitude == ToDouble(from: vc.params[.longitude]) && location.latitude == ToDouble(from: vc.params[.latitude]) {
                ok = true
            } else if let cloc = WeatherDataManager.shared.currentLocation, location == cloc && vc.index == 0 {
                ok = true
            }
            
            guard ok else { return }
            
            switch request.0 {
            case .conditions:
                print(location.city + ", " + location.country + ": " + String(describing: location.condition?.celsius))
                vc.city.text = location.city
                
                if let condition = location.condition
                {
                    vc.weather.text = condition.weather
                    vc.temp_c.text = String(describing: condition.celsius) + "°"
                }
                
                break
            case .hourly:
                print(location.city + ", " + location.country + " Hourly Weather:")
                
                let formatter = DateFormatter()
                formatter.dateFormat = Defaults.dateFormat
                
                for hour in location.hourForecast {
                    print(formatter.string(from: hour.time) + ": " + hour.weather + ", " + String(describing: hour.celsius))
                }
                
                break
            case .forecast:
                print(location.city + ", " + location.country + " Daily Weather:")
                
                let formatter = DateFormatter()
                formatter.dateFormat = Defaults.dateFormat
                
                for day in location.forecast {
                    print(formatter.string(from: day.time) + ": " + day.weather + ", " + String(describing: day.highCelsius) + " | " + String(describing: day.lowCelsius))
                }
                
                break
            default: break
            }
        }
    }
    
    func didReceiveWeatherFetchingError(request: DataManager.APIRequest, error: WeatherError?) {
        print("EROARE...")
    }
}
