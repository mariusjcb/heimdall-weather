//
//  LocationManager.swift
//  Heimdall
//
//  Created by Marius Ilie on 10/07/2017.
//  Copyright © 2017 Marius Ilie. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationManagerDelegate {
    func locationDidChange(latitude: Double, longitude: Double)
}

final class LocationManager: NSObject, CLLocationManagerDelegate {
    class var shared: LocationManager
    {
        struct Singleton
        {
            internal static let instance = LocationManager()
        }
        
        return Singleton.instance
    }
    
    let locationManager = CLLocationManager()
    var latitude = Defaults.errorDVal
    var longitude = Defaults.errorDVal
    
    var delegates = MulticastDelegate<LocationManagerDelegate>()
    
    //MARK: - Initlizer
    private override init()
    {
        super.init()
        
        if CLLocationManager.locationServicesEnabled()
        {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.requestAlwaysAuthorization()
        }
    }
    
    //MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        
        latitude = round(locValue.latitude*100)/100
        longitude = round(locValue.longitude*100)/100
        
        delegates.invoke {
            $0.locationDidChange(latitude: latitude, longitude: longitude)
        }
    }
    
    func startMonitoringSignificantLocationChanges() {
        self.locationManager.startMonitoringSignificantLocationChanges()
    }
}
