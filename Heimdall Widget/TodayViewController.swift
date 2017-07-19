//
//   TodayViewController.swift
//   Heimdall Widget
//
//   Created by Marius Ilie on 18/07/2017.
//   Copyright © 2017 Marius Ilie. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var temp: UILabel!
    
    @IBOutlet weak var city: UILabel!
    
    @IBOutlet weak var condition: UILabel!
    
    @IBOutlet weak var icon: UIImageView!
    
    @IBOutlet weak var stack: UIStackView!
    
    @IBOutlet weak var openapp: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        preferredContentSize = CGSize(width: preferredContentSize.width, height: 80);
        view?.frame.size = preferredContentSize
        
        extensionContext?.widgetLargestAvailableDisplayMode = .compact
        
        
        // add gesture
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(openMainApp))
        
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        updateWidget()
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        
        updateWidget()
        
        completionHandler(NCUpdateResult.newData)
        
    }
    
    
    func openMainApp() {
        
        guard let myAppUrl = URL(string: "Heimdall://") else { return }
        
        extensionContext?.open(myAppUrl)
        
    }
    
    
    func updateWidget()
    {
        stack.isHidden = true
        openapp.isHidden = false
        
        guard let ud = UserDefaults.init(suiteName: Defaults.suiteName) else { return }
        
        
        
        // check if exist datas
        
        guard let city = ud.string(forKey: Defaults.widget.city) else { return }
        guard let condition = ud.string(forKey: Defaults.widget.condition) else { return }
        
        guard let temp = ToDouble(from: ud.string(forKey: Defaults.widget.temperature)) else { return }
        
        guard let icon = ud.string(forKey: Defaults.widget.icon) else { return }
        
        stack.isHidden = false
        openapp.isHidden = true
        
        
        
        // set values
        
        self.city.text = city
        self.condition.text = condition
        
        self.temp.text = String(describing: Int(temp)) + Defaults.degreeSymbol
        
        self.icon.image = UIImage(named: icon)
    }
}
