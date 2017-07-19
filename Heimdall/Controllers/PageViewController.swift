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
    let backgroundImage = UIImageView(image: UIImage(named: "clear_bg"))        // Default PageView bgImage
    
    var LocationViewControllers = [UIViewController]()                          // List with all VCs from PageView
    
    
    
    //MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // add background to collection uiview
        
        backgroundImage.clipsToBounds = true
        backgroundImage.contentMode = .scaleAspectFill
        view.insertSubview(backgroundImage, at: 0)
        
        
        // set control delegates to this class
        // this class implements UIPageViewControllerDataSource and UIPageViewControllerDelegate
        
        self.dataSource = self
        self.delegate = self
        
        
        // guard for anyway...
        
        guard let firstVC = self.storyboard?.instantiateViewController(withIdentifier: "LocationVC") else {
            return
        }
        
        
        // add the firstVC to the array of LocationViewControllers (pages)
        
        LocationViewControllers.append(firstVC)
        
        
        // now updatePageControl to refresh PageView
        
        updatePageControl()
        
        
        
        // set fetching data / error delegate (append into a multicastDelegate)
        
        WeatherDataManager.shared.delegates.add(self)
        
        
        // now load tracked locations and current loc.
        
        WeatherDataManager.shared.loadData()
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    
    
    //MARK: - Pages operations
    
    
    /**
        Remove a page (viewController) from PageViewController
     
        - - -
     
        This method will **remove** a viewController from **LocationsViewController**
     
        After that will call updatePageControl() and updateIndexes()
     
        - parameter vc: A LocationVC. **Is not an optional type**
    */
    
    func remove(_ vc: LocationVC) {
        
        // don't remove first viewController
        
        guard vc.index > 0 else { return }
        
        
        
        // check if the removed vc is a page in our PageVC
        
        guard let index = LocationViewControllers.index(of: vc) else { return }
        
        // remove from LocationViewControllers
        
        LocationViewControllers.remove(at: index)
        
        
    
        // update PageViewController datas and pages index
        
        updatePageControl(direction: .reverse, to: index-1)
        updateIndexes()
    }
    
    
    
    /**
     Move from the current page to a specified page or
     
     This method also refresh the PageViewController
     
     - - -
     
     This method **return void** if the index is out of the **LocationViewControllers** range
     
     Background of pageView will be also changed
     
     - parameter direction: UIPageViewControllerNavigationDirection, default is **.forward**
     - parameter to: **Optional(**Int**)**, default is **nil**.
     If is nil the method will simply refresh the pageVC
     */
    
    func updatePageControl(direction: UIPageViewControllerNavigationDirection = .forward, to index: Int? = nil) {
        let currentPage = index ?? (viewControllers!.first as? LocationVC)?.index ?? 0
        
        
        // check if the target vc is a page in our PageVC
        
        guard let locationvc = LocationViewControllers[currentPage] as? LocationVC else { return }
        
        
        // set targetvc as the single presented vc in pageview
        
        setViewControllers([locationvc],
                           direction: direction,
                           animated: true,
                           completion: nil)
        
        
        // update layers
        
        locationvc.updateLayers()
        
        
        // change pagevc background
        
        backgroundImage.changeImage(
            with: UIImage(named: (locationvc.location?.condition?.icon ?? "clear") + "_bg")
        )
    }
    
    
    
    /**
     Parse the LocationViewControllers array and update indexes to each LocationVC
     
     This method also refresh each **LocationVC** layers
     */
    
    func updateIndexes() {
        for locvc in LocationViewControllers {
            guard let locvc = locvc as? LocationVC else { continue }
            guard let index = LocationViewControllers.index(of: locvc) else { continue }
            
            
            // update index
            
            locvc.view.tag = index
            locvc.index = index
            
            
            // update layers

            locvc.updateLayers()
        }
    }
    
    
    
    //MARK: Set location page
    
    
    /**
     Change shown location or add a new page for specified location
     
     This method also refresh the PageViewController
     
     - - -
     
     This method will create new page for your target location
     or will update an existing page and its UI
     
     
     Attention:
     ==========
     If the location is same with your current location,
     this method will affect the first page of PageVC
     
     - parameter location: the target location. Type: **Location**, it not an optional type.
     */
    
    func set(location: Location) {
        var existVCWithLocation = false
        
        
        // parse LocationViewControllers reversed
        
        for vc in LocationViewControllers.reversed() {
            let vc = vc as! LocationVC
            var ok = false
            
            
            if location.city == vc.location?.city && location.countryCode == vc.location?.countryCode
            {
                
                // exists a viewcontroller who shown this location
                
                ok = true
                
            } else if let cLoc = WeatherDataManager.shared.currentLocation,
                location.city == cLoc.city && location.countryCode == cLoc.countryCode && vc.index == 0
            {
                
                // is current user location
    
                ok = true
                
                // remove "removeBtn" to prevent removing the current location page
                
                vc.removeBtn?.removeFromSuperview()
            }
            
            
            
            // exist a page or is the current location...
            
            guard ok else { continue }
            
            if vc.location == nil {
                
                // set location - the observer will automatically call updateUI
                
                vc.location = location
                
                
                
                // if is current location viewController, refresh pagevc to update the background
                
                if vc.index == 0 {
                    updatePageControl()
                }
            } else {
                
                // if page exists then updateUI because location property is weak var !!!
                
                vc.updateUI()
            }
            
            
            
            // mark that exists a vc with this location to prevent creating a new page
            
            existVCWithLocation = true
        }
        
        
        
        if existVCWithLocation == false {

            // create the new location page
            
            let newVC = self.storyboard?.instantiateViewController(withIdentifier: "LocationVC") as! LocationVC
            
            
            
            // set location and index
            
            newVC.location = location
            newVC.index = LocationViewControllers.count
            
            
            
            // append the new VC and refresh pageViewController
            
            LocationViewControllers.append(newVC)
            updatePageControl()
        }
    }
    
    
    
    
    //MARK: - UIPageViewControllerDataSource
    
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
        return (pageViewController.viewControllers!.first as? LocationVC)?.index ?? 0
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        let locationvc = pendingViewControllers[0] as? LocationVC
        backgroundImage.changeImage(with: UIImage(named: (locationvc?.location?.condition?.icon ?? "clear") + "_bg"))
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed == false else { return }
        
        let locationvc = previousViewControllers[0] as? LocationVC
        backgroundImage.changeImage(with: UIImage(named: (locationvc?.location?.condition?.icon ?? "clear") + "_bg"))
    }
    
    
    
    
    //MARK: - WeatherDataManagerDelegate
    
    func weatherDataWill(request: DataManager.APIRequest) {
        printLog("LOADING...")
    }
    
    func weatherDidChange(for location: Location, request: DataManager.APIRequest) {
        set(location: location)
    }
    
    func didReceiveWeatherFetchingError(request: DataManager.APIRequest, error: WeatherError?) {
        printLog("EROARE...")
    }
}
