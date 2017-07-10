//
//  ViewController.swift
//  Heimdall
//
//  Created by Marius Ilie on 08/07/2017.
//  Copyright © 2017 Marius Ilie. All rights reserved.
//

import UIKit

class ViewController: UIViewController, WeatherDataManagerDelegate {
    
    @IBOutlet weak var city: UILabel!
    
    @IBOutlet weak var weather: UILabel!
    
    @IBOutlet weak var temp_c: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WeatherDataManager.shared.delegate += self
        
        _ = LocationManager.shared
        LocationManager.shared.startMonitoringSignificantLocationChanges()
    }

    //MARK: WeatherDataManagerDelegate
    
    func weatherDataWill(request: DataManager.Request) {
        print("Will request...")
    }
    
    func weatherDidChange(for location: Location, request: DataManager.Request) {
        print(location.city + ", " + location.country + ": " + String(describing: location.condition?.celsius))
        city.text = location.city
        
        if let condition = location.condition
        {
            weather.text = condition.weather 
            temp_c.text = String(describing: condition.celsius) + "°"
        }
    }
    
    func didReceiveWeatherFetchingError(request: DataManager.Request, error: WeatherError?) {
        print("EROARE...")
    }
}

