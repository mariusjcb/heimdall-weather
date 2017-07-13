//
//  ViewController.swift
//  Heimdall
//
//  Created by Marius Ilie on 08/07/2017.
//  Copyright © 2017 Marius Ilie. All rights reserved.
//

import UIKit

class LocationVC: UIViewController, UICollectionViewDataSource {
    var index = 0
    weak var location: Location? = nil {
        didSet {
            updateUI()
        }
    }
    
    @IBAction func on(_ sender: Any) {
        WeatherDataManager.weather(forLatitude: 48, longitude: 19)
        WeatherDataManager.weather(forLatitude: 53, longitude: 14)
    }
    
    @IBOutlet weak var city: UILabel!
    
    @IBOutlet weak var weather: UILabel!
    
    @IBOutlet weak var temp_c: UILabel!
    
    @IBOutlet weak var hourly: UICollectionView!
    
    @IBOutlet weak var daily: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hourly.dataSource = self
        hourly.register(UINib(nibName: "HourForecastCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "hourCell")
        hourly.backgroundColor = UIColor.clear
        hourly.backgroundView = UIView()
        
        /*daily.delegate = self
        daily.dataSource = self*/
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    func updateUI() {
        guard let location = location else { return }
        
        print(location.city + ", " + location.country + ": " + String(describing: location.condition?.celsius))
        city?.text = location.city
        
        if let condition = location.condition
        {
            weather?.text = condition.weather
            temp_c?.text = String(describing: Int(condition.celsius)) + "°"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = Defaults.dateFormat
        
        print(location.city + ", " + location.country + " Hourly Weather:")
        for hour in location.hourForecast {
            print(formatter.string(from: hour.time) + ": " + hour.weather + ", " + String(describing: hour.celsius))
        }
        
        hourly?.reloadData()
        
        print(location.city + ", " + location.country + " Daily Weather:")
        for day in location.forecast {
            print(formatter.string(from: day.time) + ": " + day.weather + ", " + String(describing: day.highCelsius) + " | " + String(describing: day.lowCelsius))
        }
    }
    
    
    //MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return location?.hourForecast.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        
        let cell = hourly.dequeueReusableCell(withReuseIdentifier: "hourCell", for: indexPath) as! HourForecastCollectionViewCell
        guard let hour = location?.hourForecast[indexPath.item] else { return cell }
        
        cell.time.text = formatter.string(from: hour.time)
        cell.icon.image = UIImage(named: hour.icon)
        cell.temp.text = "\(Int(hour.celsius))°"
        
        return cell
    }
}

