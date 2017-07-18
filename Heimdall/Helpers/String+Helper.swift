//
//  String+Helper.swift
//  Heimdall
//
//  Created by Marius Ilie on 18/07/2017.
//  Copyright © 2017 Marius Ilie. All rights reserved.
//

import Foundation
import UIKit

extension String {
    /**
     Replace variables like {VAR_NAME} from a "dynamic string"
     
     **All variables need to be uppercase**
     
     - parameter variable: The name of variable from DynamicString
     - parameter with: The string to replace varible from DynamicString
     */
    mutating func replace(variable: String, with replace: String) {
        self = self.replacingOccurrences(of: "{\(variable.uppercased())}", with: replace)
    }
    
    func toDouble(usingSeparator separator: String = ".") -> Double?
    {
        let formatter = NumberFormatter()
        formatter.decimalSeparator = separator
        
        return formatter.number(from: self.contains("--") ? "0.0" : self)?.doubleValue
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.height
    }
    
    func width(forFont font: UIFont) -> CGFloat{
        let attributes = NSDictionary(object: font, forKey:NSFontAttributeName as NSCopying)
        let sizeOfText = self.size(attributes: (attributes as! [String : AnyObject]))
        
        return sizeOfText.width
    }
}
