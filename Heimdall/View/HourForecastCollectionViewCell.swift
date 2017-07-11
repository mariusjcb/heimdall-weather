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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
