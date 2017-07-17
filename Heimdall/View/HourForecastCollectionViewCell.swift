//
//  HourForecastCollectionViewCell.swift
//  Heimdall
//
//  Created by Marius Ilie on 11/07/2017.
//  Copyright © 2017 Marius Ilie. All rights reserved.
//

import UIKit

class HourForecastCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var time: UILabel!

    @IBOutlet weak var icon: UIImageView!
    
    @IBOutlet weak var temp: UILabel!

    /*convenience init(time: String, icon: String, temp: String) {
        self.init()
        
        self.time.text = time
        self.icon.image = UIImage(named: icon)
        self.temp.text = temp + "°"
    }*/
}
