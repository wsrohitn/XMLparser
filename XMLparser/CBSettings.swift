//
//  CBSettings.swift
//  XMLparser
//
//  Created by Rohit Natarajan on 10/03/2016.
//  Copyright © 2016 Rohit Natarajan. All rights reserved.
//

import Foundation
import WsCouchBasic
import WsBase

public protocol CBSettingsProtocol {
    var hostName: String {
        get
    }
    var bucketName: String {
        get
    }
}

class CBSettings : CBLocalDatabaseSettings, CBReplicationSettings, CBSettingsProtocol {
    
    static let sharedInstance = CBSettings()
    
    let hostName = "https://abse.whitespace.co.uk"
    let bucketName = "simulator"
    let name = "localdatabase"
    let url = "https://abse.whitespace.co.uk/simulator"
    
    private var _userName : String?
    private var _password : String?
    
    var userName: String? { return _userName }
    var password: String? { return _password }
    
    func setCredentials( userName : String?, password : String? )
    {
        _userName = userName
        _password = password
    }
    
    func initialiseViews(forDatabase database: CBLDatabase) {
        print("Initialise views for database")
        makeExchangeRatesView(database)
    }
    
    private func makeExchangeRatesView(db: CBLDatabase) {
        let view = db.viewNamed("ExchangeRatesView")
        view.setMapBlock( { (doc, emit) -> Void in
            if let type = doc["type"] as? String where type == "exchangeRates",
                let baseCurrency = doc["baseCurrency"] as? String,
                let createdAt = doc["createdAt"] as? String,
                let userName = doc["userName"] as? String {
                    var dict = StringKeyDict()
                    dict["userName"] = userName
                    dict["createdAt"] = createdAt
                    dict["baseCurrency"] = baseCurrency
                    emit (createdAt, dict)
            }
            }, version: "4")
    }
    
    var filteredPullChannels: [String]? {
        return nil
    }
    
    var allowPush: Bool {
        return true
    }
}