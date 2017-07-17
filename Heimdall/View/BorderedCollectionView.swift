//
//  BorderedCollectionView.swift
//  Heimdall
//
//  Created by Marius Ilie on 17/07/2017.
//  Copyright © 2017 Marius Ilie. All rights reserved.
//

import UIKit

class BorderedCollectionView: UICollectionView {
    
    let topBorder = CALayer()
    
    let bottomBorder = CALayer()
    
    func updateLayers() {
        let width = contentSize.width > frame.width ? contentSize.width : frame.width
        
        topBorder.frame = CGRect(x: 0, y: 1, width: width, height: 1)
        bottomBorder.frame = CGRect(x: 0, y: frame.height-1, width: width, height: 1)
        
        setNeedsLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        topBorder.borderColor = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 0.3).cgColor
        topBorder.borderWidth = 1;
        layer.addSublayer(topBorder)
        
        bottomBorder.borderColor = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 0.3).cgColor;
        bottomBorder.borderWidth = 1;
        layer.addSublayer(bottomBorder)
        
        updateLayers()
    }
}
