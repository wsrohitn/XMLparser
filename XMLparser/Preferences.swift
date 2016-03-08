//
//  Preferences.swift
//  XMLparser
//
//  Created by Rohit Natarajan on 08/03/2016.
//  Copyright © 2016 Rohit Natarajan. All rights reserved.
//

import Foundation

class Preferences
{
    enum Id : String { case baseCurrency = "baseCurrency", favourites = "favourites" }
    static func readString( id : Id, defaultValue : String = "" ) -> String {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let ob = defaults.valueForKey(id.rawValue) {
            return ob as? String ?? defaultValue
        }
        return defaultValue
    }
    static func writeString( id : Id, value : String )
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue( value, forKey: id.rawValue )
        //print( "Preferences", id.rawValue, value )
    }
}
