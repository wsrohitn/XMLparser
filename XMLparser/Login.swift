//
//  Login.swift
//  Clearance
//
//  Created by David on 02/03/2015.
//  Copyright (c) 2015 Jonathan Clarke. All rights reserved.
//

import Foundation
import WsCouchBasic
import WsBase

class Login {
    static let sharedInstance = Login()
    private var _isValid: Bool = false
    
    private var myCBSettings : CBSettingsProtocol?
    func setCBSettings( settings : CBSettingsProtocol )
    {
        myCBSettings = settings
        checkForStoredPassword()
    }
    
    var isValid: Bool {
        return _isValid
    }
    
    var hostName: String {
        if let settings = myCBSettings {
            return settings.hostName
        }
        print( "setCBSettings has not been called")
        return ""
    }
    var database: String {
        if let settings = myCBSettings {
            return settings.bucketName
        }
        print( "setCBSettings has not been called")
        return ""
    }
    
    var databaseUrl: String {
        return "\(hostName)/\(database)"
    }
    
    private class func sha256(data : NSData) -> NSData {
        var hash = [UInt8](count: Int(CC_SHA256_DIGEST_LENGTH), repeatedValue: 0)
        CC_SHA256(data.bytes, CC_LONG(data.length), &hash)
        let res = NSData(bytes: hash, length: Int(CC_SHA256_DIGEST_LENGTH))
        return res
    }
    
    private class func createHash(s: String) -> String {
        if s.isEmpty {
            return s
        }
        
        let hash = Login.sha256(s.dataUsingEncoding(NSUTF8StringEncoding)!)
        return hash.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
    }
    
    private class func createCredentialHashForUser(user: String, withPassword password: String, forUrl url: String) -> String {
        return Login.createHash("\(user):\(password)@\(url)")
    }
    
    private func createCedentialHash() -> String {
        let user = self.userName ?? ""
        let password = self.password ?? ""
        return Login.createCredentialHashForUser(user, withPassword: password, forUrl: databaseUrl)
    }
    
    private var currentUser: String?
    var userName: String? {
        get {
            return currentUser
        }
        set (s) {
            if let new_user = s {
                if let old_user = currentUser {
                    if new_user == old_user {
                        return;
                    }
                }
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setValue(new_user, forKey: "userName")
                defaults.synchronize()
            }
            else {
                if currentUser != nil {
                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.removeObjectForKey("userName")
                    defaults.synchronize()
                }
            }
            currentUser = s
            _isValid = false
        }
    }
    var password: String? {
        didSet {
            _isValid = false
        }
    }
    
    private var validatedHash: String {
        get {
            return NSUserDefaults.standardUserDefaults().valueForKey("validatedLoginHash") as? String ?? ""
        }
        set (s) {
            let defaults = NSUserDefaults.standardUserDefaults()
            if s.isEmpty {
                defaults.removeObjectForKey("validatedLoginHash")
            }
            else {
                defaults.setValue(s, forKey: "validatedLoginHash")
            }
            defaults.synchronize()
        }
    }
    
    func logout()
    {
        if let user = self.currentUser {
            SavedPassword.deleteForUser(user)
        }
        _isValid = false
    }
    
    func getStoredPassword() -> String? {
        if let user = self.currentUser {
            let validated_hash = self.validatedHash
            if !validated_hash.isEmpty {
                if let password = SavedPassword.getForUser(user) {
                    if validated_hash == Login.createCredentialHashForUser(user, withPassword: password, forUrl: self.databaseUrl) {
                        self.password = password
                        _isValid = true
                        return password
                    }
                }
            }
        }
        return nil
    }
    
    func validateAndCallback(callback: (isOK: Bool) ->()) {
        var details = ( currentUser == nil ? "nil" : currentUser! ) // + "/" + ( password == nil ? "nil" : password! )
        if let pwd = password where !pwd.isEmpty {
            let len = pwd.characters.count
            var stars = "*"
            for _ in 1 ..< len {
                stars += "*"
            }
            details += " / \(stars)"
        }
        if currentUser == nil || password == nil {
            XCGLogger.defaultInstance().warning( "validateAndCallback fail because \(details)")
            callback(isOK: false)
            return
        }
        XCGLogger.defaultInstance().warning( "validateAndCallback trying \(details)")
        
        JsonFetcher.fetchJsonFromUrl(self.databaseUrl, forUser: currentUser!, withPassword: self.password!) {
            (result: JsonFetcher.JsonResult) in
            var is_valid: Bool = result.hasData
            if is_valid {
                XCGLogger.defaultInstance().warning( "validateAndCallback success \(details)")
                self.validatedHash = self.createCedentialHash()
                SavedPassword.setForUser(self.currentUser!, value: self.password!)
            }
            else {
                if (result.error ?? "") != "cancelled" {
                    let validated_hash = self.validatedHash
                    if (!validated_hash.isEmpty) && (validated_hash == self.createCedentialHash()) {
                        XCGLogger.defaultInstance().warning( "validateAndCallback ok locally \(details)")
                        is_valid = true
                    }
                }
                else {
                    XCGLogger.defaultInstance().warning( "validateAndCallback failed \(details)")
                }
            }
            self._isValid = is_valid
            callback(isOK: is_valid)
        }
    }
    
    
    init() {
        // checkForStoredPassword
    }
    
    private func checkForStoredPassword()
    {
        currentUser = NSUserDefaults.standardUserDefaults().valueForKey("userName") as? String
        self._isValid = (getStoredPassword() != nil)
    }
    
}