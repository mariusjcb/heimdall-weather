//
//  CGPoint+Helper.swift
//  Heimdall
//
//  Created by Marius Ilie on 18/07/2017.
//  Copyright © 2017 Marius Ilie. All rights reserved.
//

import Foundation
import UIKit

extension CGPoint {
    func distance(to b: CGPoint) -> CGFloat {
        let xDist = self.x - b.x
        let yDist = self.y - b.y
        
        return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
    }
}
