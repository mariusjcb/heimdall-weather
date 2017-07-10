//
//  DefExtensions.swift
//  Heimdall
//
//  Created by Marius Ilie on 08/07/2017.
//  Copyright © 2017 Marius Ilie. All rights reserved.
//

import Foundation

extension Defaults.RestAPI {
    internal static var AuthenticatedURLString: String? {
        var url = Defaults.RestAPI.URL.authenticatedURLFormat.rawValue
        
        url.replace(variable: DynamicVariables.baseurl.rawValue, with: Defaults.RestAPI.URL.baseURL.rawValue)
        
        guard let settings = object("Info", Defaults.settingsPlistDictionary) as? [String : Any] else {
            return url
        }
        
        if let key = settings[Defaults.RestAPI.keySettingsProperty] as? String {
            url.replace(variable: DynamicVariables.key.rawValue, with: key)
        }
        
        return url
    }
}
