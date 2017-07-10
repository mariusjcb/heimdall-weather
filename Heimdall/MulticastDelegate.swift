//
//  MulticastDelegate.swift
//  Heimdall
//
//  Created by Marius Ilie on 11/07/2017.
//  Copyright © 2017 Marius Ilie. All rights reserved.
//

import Foundation

class MulticastDelegate<T> {
    let delegates = NSHashTable<AnyObject>.weakObjects()
    
    func add(_ delegate: T) {
        delegates.add(delegate as AnyObject)
    }
    
    func remove(_ delegate: T) {
        delegates.remove(delegate as AnyObject)
    }
    
    func invoke(_ completionHandler: (_ delegate: T) -> ()) {
        for delegate in delegates.allObjects.reversed() {
            guard let delegate = delegate as? T else { continue }
            completionHandler(delegate)
        }
    }
}
