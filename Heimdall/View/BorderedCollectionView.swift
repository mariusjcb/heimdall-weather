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
    
    
    /**
     This method update width of top and bottom borders and call *setNeedsLayout()*
     */
    
    func updateLayers() {
        let width = contentSize.width > frame.width ? contentSize.width : frame.width
        
        topBorder.frame = CGRect(x: 0, y: 1, width: width, height: 1)
        bottomBorder.frame = CGRect(x: 0, y: frame.height-1, width: width, height: 1)
        
        setNeedsLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        
        // set top border
        
        topBorder.borderColor = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 0.3).cgColor
        topBorder.borderWidth = 1;
        layer.addSublayer(topBorder)
        
        
        
        // set bottom border
        
        bottomBorder.borderColor = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 0.3).cgColor;
        bottomBorder.borderWidth = 1;
        layer.addSublayer(bottomBorder)
        
        
        // update layers
        
        updateLayers()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateLayers()
    }
}
