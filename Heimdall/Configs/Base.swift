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
    static let trackedUDName            =   "trackedLocationsUD"
    static let errorDVal                =   -99999.999
    static let degreeSymbol             =   "°"

    static let logs                     =   true
    static let debugJSON                =   false
    static let jsonKeySeparator         =   " => "
    static let bigUpdatesInterval       =   24
    
    static let dateFormat               =   "HH:mm yy-MM-dd Z"
    
    struct RestAPI { }
    
    struct widget {
        static let city                 =   "todayExtension.city"
        static let temperature          =   "todayExtension.temperature"
        static let condition            =   "todayExtension.condition"
        static let icon                 =   "todayExtension.icon"
    }
}
