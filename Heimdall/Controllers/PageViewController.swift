//
//  PageViewController.swift
//  Heimdall
//
//  Created by Marius Ilie on 11/07/2017.
//  Copyright © 2017 Marius Ilie. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, WeatherDataManagerDelegate
{
    let backgroundImage = UIImageView(image: UIImage(named: "colorful-bokeh-bubbles-effect-iphone-6-dark-bubble-bokeh-rain-drops-flare-outside-iphone-6-wallpaper-18"))
    
    var LocationViewControllers = [UIViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundImage.contentMode = UIViewContentMode.scaleAspectFill
        backgroundImage.clipsToBounds = true
        self.view.insertSubview(backgroundImage, at: 0)
        
        self.dataSource = self
        self.delegate = self
        
        guard let firstVC = self.storyboard?.instantiateViewController(withIdentifier: "LocationVC") else {
            return
        }
        
        LocationViewControllers.append(firstVC)
        updatePageControl()
        
        WeatherDataManager.shared.delegates.add(self)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vcIndex = LocationViewControllers.index(of: viewController) else {
            return nil
        }
        
        let prevIndex = vcIndex - 1
        
        guard LocationViewControllers.count > prevIndex && prevIndex >= 0 else {
            return nil
        }
        
        return LocationViewControllers[prevIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vcIndex = LocationViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = vcIndex + 1
        
        guard LocationViewControllers.count > nextIndex else {
            return nil
        }
        
        return LocationViewControllers[nextIndex]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return LocationViewControllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let vcIndex = LocationViewControllers.index(of: pageViewController) else {
            return 0
        }
        
        return vcIndex
    }
    
    func updatePageControl() {
        let currentPage = viewControllers!.first?.view.tag ?? 0
        
        setViewControllers([LocationViewControllers[currentPage]],
                           direction: .forward,
                           animated: true,
                           completion: nil)
    }
    
    //MARK: - WeatherDataManagerDelegate
    
    func weatherDataWill(request: DataManager.APIRequest) {
        print("LOADING...")
    }
    
    func weatherDidChange(for location: Location, request: DataManager.APIRequest) {
        var okVC = false
        
        for vc in LocationViewControllers.reversed() {
            let vc = vc as! LocationVC
            var ok = false
            
            if location.city == vc.location?.city && location.countryCode == vc.location?.countryCode {
                ok = true
            } else if let cLoc = WeatherDataManager.shared.currentLocation,
                location.city == cLoc.city && location.countryCode == cLoc.countryCode && vc.index == 0 {
                ok = true
            }
            
            guard ok else { continue }
            
            if vc.location == nil {
                vc.location = location
            } else {
               vc.updateUI()
            }
            
            okVC = true
        }
        
        if okVC == false {
            let newVC = self.storyboard?.instantiateViewController(withIdentifier: "LocationVC") as! LocationVC
            
            newVC.location = location
            newVC.index = LocationViewControllers.count
            
            LocationViewControllers.append(newVC)
            updatePageControl()
        }
    }
    
    func didReceiveWeatherFetchingError(request: DataManager.APIRequest, error: WeatherError?) {
        print("EROARE...")
    }
}
