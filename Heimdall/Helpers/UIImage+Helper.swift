//
//  UIImageView+Helper.swift
//  Heimdall
//
//  Created by Marius Ilie on 19/07/2017.
//  Copyright © 2017 Marius Ilie. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView
{
    /**
     Helper to animate changes between current UIImage and the target
     
     - Attention: If image is nil helper will be stoped without any errors
     Be sure that consider this situation
     
     - parameter with: The target image. **An optional UIImage**
     */
    
    func changeImage(with background: UIImage?) {
        guard let background = background else { return }
        
        UIView.transition (
            with: self,
            duration:0.5,
            options: .transitionCrossDissolve,
            animations: { [weak self] in
                self?.image = background
            },
            completion: nil
        )
    }
    
}
