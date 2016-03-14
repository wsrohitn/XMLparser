//
//  ExchangeRateItem.swift
//  XMLparser
//
//  Created by Rohit Natarajan on 14/03/2016.
//  Copyright © 2016 Rohit Natarajan. All rights reserved.
//

import Foundation
import WsBase

class ExchangeRateItem {
    var targetCurrency = ""
    var exchangeRate = ""
    
    func makeDict() -> StringKeyDict{
        var dict = StringKeyDict()
        
        dict["targetCurrency"] = targetCurrency
        dict["exchangeRate"] = exchangeRate
        
        return dict
    }
}