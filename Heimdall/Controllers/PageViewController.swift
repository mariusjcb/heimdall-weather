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
    let backgroundImage = UIImageView(image: UIImage(named: "clear_bg"))
    var LocationViewControllers = [UIViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundImage.clipsToBounds = true
        backgroundImage.contentMode = .scaleAspectFill
        self.view.insertSubview(backgroundImage, at: 0)
        
        self.dataSource = self
        self.delegate = self
        
        guard let firstVC = self.storyboard?.instantiateViewController(withIdentifier: "LocationVC") else {
            return
        }
        
        LocationViewControllers.append(firstVC)
        updatePageControl()
        
        WeatherDataManager.shared.delegates.add(self)
        WeatherDataManager.shared.loadData()
    }
    
    
    //MARK: Pages operations
    func change(background: UIImage?) {
        guard let background = background else { return }
        UIView.transition(with: self.backgroundImage,
                          duration:0.5,
                          options: .transitionCrossDissolve,
                          animations: { self.backgroundImage.image = background },
                          completion: nil)
    }
    
    func remove(_ vc: LocationVC) {
        vc.view.tag = vc.index - 1
        guard let index = LocationViewControllers.index(of: vc) else { return }
        LocationViewControllers.remove(at: index)
        updateIndexes()
        updatePageControl()
    }
    
    func updatePageControl() {
        let currentPage = viewControllers!.first?.view.tag ?? 0
        guard let locationvc = LocationViewControllers[currentPage] as? LocationVC else { return }
        
        setViewControllers([locationvc],
                           direction: .forward,
                           animated: true,
                           completion: nil)
        
        change(background: UIImage(named: (locationvc.location?.condition?.icon ?? "clear") + "_bg"))
    }
    
    func updateIndexes() {
        for locvc in LocationViewControllers {
            guard let locvc = locvc as? LocationVC else { continue }
            guard let index = LocationViewControllers.index(of: locvc) else { continue }
            
            locvc.view.tag = index
            locvc.index = index
        }
    }
    
    
    //MARK: Set location page
    func set(location: Location) {
        var okVC = false
        
        for vc in LocationViewControllers.reversed() {
            let vc = vc as! LocationVC
            var ok = false
            
            if location.city == vc.location?.city && location.countryCode == vc.location?.countryCode {
                ok = true
            } else if let cLoc = WeatherDataManager.shared.currentLocation,
                location.city == cLoc.city && location.countryCode == cLoc.countryCode && vc.index == 0 {
                ok = true
                vc.removeBtn.removeFromSuperview()
            }
            
            guard ok else { continue }
            
            if vc.location == nil {
                vc.location = location
                if vc.index == 0 {
                    updatePageControl()
                }
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
    
    
    
    //MARK: UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vcIndex = LocationViewControllers.index(of: viewController) else {
            return nil
        }
        
        let prevIndex = vcIndex - 1
        
        guard prevIndex >= 0 else {
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
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        let locationvc = pendingViewControllers[0] as? LocationVC
        change(background: UIImage(named: (locationvc?.location?.condition?.icon ?? "clear") + "_bg"))
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed == false else { return }
        
        let locationvc = previousViewControllers[0] as? LocationVC
        change(background: UIImage(named: (locationvc?.location?.condition?.icon ?? "clear") + "_bg"))
    }
    
    //MARK: - WeatherDataManagerDelegate
    
    func weatherDataWill(request: DataManager.APIRequest) {
        print("LOADING...")
    }
    
    func weatherDidChange(for location: Location, request: DataManager.APIRequest) {
        set(location: location)
    }
    
    func didReceiveWeatherFetchingError(request: DataManager.APIRequest, error: WeatherError?) {
        print("EROARE...")
    }
}
