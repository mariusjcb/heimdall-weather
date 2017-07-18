//
//  ViewController.swift
//  Heimdall
//
//  Created by Marius Ilie on 08/07/2017.
//  Copyright © 2017 Marius Ilie. All rights reserved.
//

import UIKit

class LocationVC: UIViewController, UICollectionViewDataSource, UITableViewDataSource
{
    var index = 0
    
    weak var location: Location? = nil {
        didSet {
            updateUI()
        }
    }
    
    @IBAction func on(_ sender: Any) {
        let addlocationvc = storyboard?.instantiateViewController(withIdentifier: "NewLocationViewController")
        UIApplication.topViewController()?.present(addlocationvc!, animated: true, completion: nil)
    }
    
    @IBOutlet weak var removeBtn: UIButton!
    @IBAction func remove(_ sender: UIButton) {
        guard let location = location else { return }
        WeatherDataManager.shared.untrack(latitude: location.latitude, longitude: location.longitude)
        
        guard let parentpvc = parent as? PageViewController else { return }
        parentpvc.remove(self)
    }
    
    @IBOutlet weak var city: UILabel!
    
    @IBOutlet weak var weather: UILabel!
    
    @IBOutlet weak var temp_c: UILabel!
    
    @IBOutlet weak var hourly: BorderedCollectionView!
    
    @IBOutlet weak var daily: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        daily.dataSource = self
        daily.register(UINib(nibName: "DailyForecastTableViewCell", bundle: nil), forCellReuseIdentifier: "dayCell")
        
        hourly.dataSource = self
        hourly.register(UINib(nibName: "HourForecastCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "hourCell")
        hourly.backgroundColor = UIColor.clear
        hourly.backgroundView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    func updateUI() {
        guard let location = location else { return }
        
        printLog(location.city + ", " + location.country + ": " + String(describing: location.condition?.celsius))
        city?.text = location.city
        
        if let condition = location.condition
        {
            weather?.text = condition.weather
            temp_c?.text = String(describing: Int(condition.celsius)) + "°"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = Defaults.dateFormat
        
        printLog(location.city + ", " + location.country + " Hourly Weather:")
        for hour in location.hourForecast {
            printLog(formatter.string(from: hour.time) + ": " + hour.weather + ", " + String(describing: hour.celsius))
        }
        
        printLog(location.city + ", " + location.country + " Daily Weather:")
        for day in location.forecast {
            printLog(formatter.string(from: day.time) + ": " + day.weather + ", " + String(describing: day.highCelsius) + " | " + String(describing: day.lowCelsius))
        }
        
        hourly?.reloadData()
        daily?.reloadData()
        
        hourly?.updateLayers()
    }
    
    
    //MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let hours = location?.hourForecast.filter { Calendar.current.dateComponents([.hour], from: Date(), to: $0.time).hour! < 24 }
        return hours?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        
        let cell = hourly.dequeueReusableCell(withReuseIdentifier: "hourCell", for: indexPath) as! HourForecastCollectionViewCell
        guard let hour = location?.hourForecast[indexPath.item] else { return cell }
        
        if hour.time.isToday() {
            cell.day.text = NSLocalizedString("Today", comment: "")
        } else {
            cell.day.text = NSLocalizedString("Tomorrow", comment: "")
        }
        
        cell.time.text = formatter.string(from: hour.time)
        cell.icon.image = UIImage(named: hour.icon)
        cell.temp.text = "\(Int(hour.celsius))°"
        
        return cell
    }
    
    
    //MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, dd"
        
        let cell = daily.dequeueReusableCell(withIdentifier: "dayCell", for: indexPath) as! DailyForecastTableViewCell
        guard let day = location?.forecast[indexPath.row] else { return cell }
        
        cell.day.text = day.time.isToday() ? NSLocalizedString("Today", comment: "") : formatter.string(from: day.time)
        cell.icon.image = UIImage(named: day.icon)
        cell.min.text = "\(Int(day.lowCelsius))°"
        cell.max.text = "\(Int(day.highCelsius))°"
        
        cell.backgroundColor = cell.contentView.backgroundColor
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return location?.forecast.count ?? 0
    }
}

