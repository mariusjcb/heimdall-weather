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
    //MARK: - Properties
    
    var index = 0
    
    weak var location: Location? = nil {
        didSet {
            updateUI()
        }
    }
    
    
    
    //MARK: - IBOutlets & IBActions
    
    @IBOutlet weak var city: UILabel!
    
    @IBOutlet weak var weather: UILabel!
    
    @IBOutlet weak var temp_c: UILabel!
    
    @IBOutlet weak var hourly: BorderedCollectionView!
    
    @IBOutlet weak var daily: UITableView!
    
    
    @IBAction func on(_ sender: Any) {
        // get NewLocationViewController from main storyboard
        let addlocationvc = storyboard?.instantiateViewController(withIdentifier: "NewLocationViewController")
        
        // go ahead
        UIApplication.topViewController()?.present(addlocationvc!, animated: true, completion: nil)
    }
    
    @IBOutlet weak var removeBtn: UIButton!
    @IBAction func remove(_ sender: UIButton?) {
        guard let location = location else { return }
        
        // remove location from WeatherDataManager
        
        WeatherDataManager.shared.untrack(latitude: location.latitude, longitude: location.longitude)
        
        
        
        // remove current viewController from locationsPageViewController
        
        guard let parentpvc = parent as? PageViewController else { return }
        parentpvc.remove(self)
    }
    
    
    
    //MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // set collectionView delegate with reusable cell from xib
        
        daily.dataSource = self
        
        daily.register(UINib(nibName: "DailyForecastTableViewCell",
                             bundle: nil), forCellReuseIdentifier: "dayCell")
        
        
        
        // set tableView delegate with reusable cell from xib
        
        hourly.dataSource = self
        
        hourly.register(UINib(nibName: "HourForecastCollectionViewCell",
                              bundle: nil), forCellWithReuseIdentifier: "hourCell")
        
        hourly.backgroundColor = UIColor.clear
        
        hourly.backgroundView = UIView()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        // remove location from pageView if has no forecasts
        
        if location?.forecast.count == 0 {
            remove(nil)
        }
        
        
        // else... load conditions & forecasts data
        
        updateUI()
    }
    
    
    
    func updateUI() {
        guard let location = location else { return }
        
        printLog(location.city + ", " + location.country + ": " + String(describing: location.condition?.celsius))
        
        city?.text = location.city
        
        
        
        // update condition data
        
        if let condition = location.condition {
            weather?.text = condition.weather
            temp_c?.text = String(describing: Int(condition.celsius)) + Defaults.degreeSymbol
        }
        
        
        
        // update hourly forecast (collectionView)
        
        let formatter = DateFormatter()
        formatter.dateFormat = Defaults.dateFormat
        
        printLog(location.city + ", " + location.country + " Hourly Weather:")
        
        for hour in location.hourForecast {
            printLog(formatter.string(from: hour.time) + ": " + hour.weather + ", " + String(describing: hour.celsius))
        }
        
        
        hourly?.reloadData()
        hourly?.updateLayers()
        
        
        
        // update daily forecast (tableView)
        
        printLog(location.city + ", " + location.country + " Daily Weather:")
        for day in location.forecast {
            printLog(formatter.string(from: day.time) + ": " + day.weather + ", "
                + String(describing: day.highCelsius) + " | " + String(describing: day.lowCelsius))
        }
        
        daily?.reloadData()
        
    }
    
    
    
    
    //MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // filter array to get data for only 24 hours
        
        let hours = location?.hourForecast.filter {
            Calendar.current.dateComponents([.hour],
                                            from: Date(),
                                            to: $0.time
                ).hour! < 24
        }
        
        
        // return hours or 0 if forecast doesn't exist
        
        return hours?.count ?? 0
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH a"           //  hour time formatter (ex: "HH a" means 07 AM)
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        
        
        
        // if hourforecast has count 0 or location == nil then return blank cell
        
        let cell = hourly.dequeueReusableCell(withReuseIdentifier: "hourCell", for: indexPath) as! HourForecastCollectionViewCell
        guard let hour = location?.hourForecast[indexPath.item] else { return cell }
        
        
        
        // set data
        
        if hour.time.isToday() {
            cell.day.text = NSLocalizedString("Today", comment: "")
        } else {
            cell.day.text = NSLocalizedString("Tomorrow", comment: "")
        }
        
        
        cell.time.text = formatter.string(from: hour.time)
        
        cell.icon.image = UIImage(named: hour.icon)
        
        cell.temp.text = String(describing: round(hour.celsius)) + Defaults.degreeSymbol
        
        
        
        // go ahead
        
        return cell
    }
    
    
    
    
    //MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, dd"           //  day date formatter (ex: "HH a" means 07 AM)
        
        
        
        // if forecast has count 0 or location == nil then return blank cell
        
        let cell = daily.dequeueReusableCell(withIdentifier: "dayCell", for: indexPath) as! DailyForecastTableViewCell
        guard let day = location?.forecast[indexPath.row] else { return cell }
        
        
        
        // set data
        
        cell.day.text = day.time.isToday() ? NSLocalizedString("Today", comment: "") : formatter.string(from: day.time)
        
        cell.icon.image = UIImage(named: day.icon)
        
        cell.min.text = String(describing: round(day.lowCelsius)) + Defaults.degreeSymbol
        cell.max.text = String(describing: round(day.highCelsius)) + Defaults.degreeSymbol
        
        cell.backgroundColor = cell.contentView.backgroundColor
        
        
        
        // go ahead
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return location?.forecast.count ?? 0
        
    }
}

