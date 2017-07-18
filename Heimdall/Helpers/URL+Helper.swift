//
//  URL+Helper.swift
//  Heimdall
//
//  Created by Marius Ilie on 18/07/2017.
//  Copyright © 2017 Marius Ilie. All rights reserved.
//

import Foundation

extension URL {
    /**
     Works like appendingPathComponent method but allow to append a URL Query
     
     **This function just create a new URL**
     
     - parameter path: The path which will append to the current relative URL
     */
    
    func append(_ path: String) -> URL? {
        let currentURLString = self.relativeString + path
        return URL(string: currentURLString)
    }
}
