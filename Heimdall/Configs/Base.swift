//
//  Defaults.swift
//  Heimdall
//
//  Created by Marius Ilie on 08/07/2017.
//  Copyright © 2017 Marius Ilie. All rights reserved.
//

import Foundation

struct Defaults
{
    static let settingsPlistDictionary  =   "Heimdall Settings"
    static let suiteName                =   "group.ro.iliemarius.heimdall"
    static let trackedUDName            =   "a001"
    static let errorDVal                =   -99999.999

    static let logs                     =   true
    static let debugJSON                =   false
    static let jsonKeySeparator         =   " => "
    static let bigUpdatesInterval       =   24
    
    static let dateFormat               =   "HH:mm yy-MM-dd Z"
    
    struct RestAPI { }
    
    struct widget {
        static let city                 =   "today.city"
        static let temperature          =   "today.temperature"
        static let condition            =   "today.condition"
        static let icon                 =   "today.icon"
    }
}
