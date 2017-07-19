//
//  NewLocationViewController.swift
//  Heimdall
//
//  Created by Marius Ilie on 19/07/2017.
//  Copyright © 2017 Marius Ilie. All rights reserved.
//

import UIKit

class NewLocationViewController: UIViewController, UITextFieldDelegate, WeatherDataManagerDelegate {

    private var _country = ""
    private var _city = ""
    
    @IBOutlet weak var country: UIFloatTextField! {
        didSet {
            country?.placeholderDirection = .top
        }
    }
    
    @IBOutlet weak var city: UIFloatTextField! {
        didSet {
            city?.placeholderDirection = .top
        }
    }
    
    @IBOutlet weak var searchBtn: UILoadButton!
    
    @IBOutlet weak var status: UILabel!
    
    @IBAction func onSearch(_ sender: UILoadButton) {
        guard let country = self.country.text else {
            sender.animateOut()
            return
        }
        
        guard let city = self.city.text else {
            sender.animateOut()
            return
        }
        
        
        _city = city
        _country = country
        
        WeatherDataManager.weather(forCity: _city, country: _country)
    }
    
    @IBAction func onCancel(_ sender: UILoadButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        country.delegate = self
        city.delegate = self
        
        WeatherDataManager.shared.delegates.add(self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    //MARK: WeatherDataManagerDelegate
    func weatherDataWill(request: DataManager.APIRequest) {
        searchBtn.animateIn()
        status.text = ""
    }
    
    func weatherDidChange(for location: Location, request: DataManager.APIRequest) {
        if request.0 == .forecast {
            searchBtn.animateOut()
            dismiss(animated: true, completion: nil)
        }
    }
    
    func didReceiveWeatherFetchingError(request: DataManager.APIRequest, error: WeatherError?) {
        searchBtn.animateOut()
        guard let error = error else { return }
        
        switch error {
        case .message(let type, let message):
            status.text = "\(type): \(message)"
        case .cathed(let message):
            status.text = "CATCHED: \(message)"
        case .missing(let missing):
            status.text = "JSON Missing: \(missing) for Endpoint \(request.0)"
        case .locationNotFound:
            if request.0 == .conditions {
                status.text = "ERROR: Location not found in API"
            } else {
                status.text = "ERROR: Location not found in WeatherDataManager"
            }
        default:
            status.text = "ERROR: \(error.localizedDescription)"
        }
    }
    
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
