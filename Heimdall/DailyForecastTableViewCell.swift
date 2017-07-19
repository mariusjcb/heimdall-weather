//
//  DailyForecastTableViewCell.swift
//  Heimdall
//
//  Created by Marius Ilie on 17/07/2017.
//  Copyright © 2017 Marius Ilie. All rights reserved.
//

import UIKit

class DailyForecastTableViewCell: UITableViewCell {

    @IBOutlet weak var day: UILabel!
    
    @IBOutlet weak var icon: UIImageView!
    
    @IBOutlet weak var min: UILabel!
    
    @IBOutlet weak var max: UILabel!
    
    convenience init(day: String, icon: String, min: String, max: String) {
        self.init()
        
        self.day.text = day
        self.icon.image = UIImage(named: icon)
        self.min.text = min + Defaults.degreeSymbol
        self.max.text = max + Defaults.degreeSymbol
    }
    
}
