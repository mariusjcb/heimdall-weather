//
//  ViewController.swift
//  Heimdall
//
//  Created by Marius Ilie on 08/07/2017.
//  Copyright © 2017 Marius Ilie. All rights reserved.
//

import UIKit

class LocationVC: UIViewController {
    
    var index = 0
    var params: DataManager.APIRequestParams = [:]
    weak var location: Location? {
        didSet {
            guard let location = location else { return }
            
            print(location.city + ", " + location.country + ": " + String(describing: location.condition?.celsius))
            city.text = location.city
            
            if let condition = location.condition
            {
                weather.text = condition.weather
                temp_c.text = String(describing: condition.celsius) + "°"
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = Defaults.dateFormat
            
            print(location.city + ", " + location.country + " Hourly Weather:")
            for hour in location.hourForecast {
                print(formatter.string(from: hour.time) + ": " + hour.weather + ", " + String(describing: hour.celsius))
            }
            
            print(location.city + ", " + location.country + " Daily Weather:")
            for day in location.forecast {
                print(formatter.string(from: day.time) + ": " + day.weather + ", " + String(describing: day.highCelsius) + " | " + String(describing: day.lowCelsius))
            }
        }
    }
    
    @IBOutlet weak var city: UILabel!
    
    @IBOutlet weak var weather: UILabel!
    
    @IBOutlet weak var temp_c: UILabel!
    
    @IBOutlet weak var hourly: UICollectionView!
    
    @IBOutlet weak var daily: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*hourly.delegate = self
        hourly.dataSource = self
        
        daily.delegate = self
        daily.dataSource = self*/
    }
}

