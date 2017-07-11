//
//  PageViewController.swift
//  Heimdall
//
//  Created by Marius Ilie on 11/07/2017.
//  Copyright © 2017 Marius Ilie. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController, WeatherDataManagerDelegate {
    var vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LocationVC1") as! LocationVC
    
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
            let vc = vc as! LocationVC
            var ok = false
            
            if location.city == vc.params[.city] && location.country == vc.params[.country] {
                ok = true
            } else if location.longitude == ToDouble(from: vc.params[.longitude]) && location.latitude == ToDouble(from: vc.params[.latitude]) {
                ok = true
            } else if let cLoc = WeatherDataManager.shared.currentLocation, location == cLoc && vc.index == 0 {
                ok = true
            }
            
            vc.location = location
            guard ok else { continue }
        }
    }
    
    func didReceiveWeatherFetchingError(request: DataManager.APIRequest, error: WeatherError?) {
        print("EROARE...")
    }
}
