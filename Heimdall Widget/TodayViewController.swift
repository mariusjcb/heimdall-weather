//
//  TodayViewController.swift
//  Heimdall Widget
//
//  Created by Marius Ilie on 18/07/2017.
//  Copyright © 2017 Marius Ilie. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var temp: UILabel!
    
    @IBOutlet weak var city: UILabel!
    
    @IBOutlet weak var condition: UILabel!
    
    @IBOutlet weak var icon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        preferredContentSize = CGSize(width: preferredContentSize.width, height: 80);
        view?.frame.size = preferredContentSize
        
        extensionContext?.widgetLargestAvailableDisplayMode = .compact
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        updateWidget()
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        
        updateWidget()
        
        completionHandler(NCUpdateResult.newData)
        
    }
    
    
    func updateWidget()
    {
        guard let ud = UserDefaults.init(suiteName: Defaults.suiteName) else {
            return
        }
        
        city.text = ud.string(forKey: Defaults.widget.city)
        
        condition.text = ud.string(forKey: Defaults.widget.condition)
        
        temp.text = "\(ud.string(forKey: Defaults.widget.temperature) ?? "--")°"
        
        icon.image = UIImage(named: ud.string(forKey: Defaults.widget.icon) ?? "clear")
    }
}
