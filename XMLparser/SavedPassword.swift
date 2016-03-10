//
//  SavedPassword.swift
//  WsSharedEdit
//
//  Created by David on 11/12/2015.
//  Copyright © 2015 Ben Bialobrzycki. All rights reserved.
//

import Foundation
import Security
import WsBase

//based on https://github.com/chrishulbert/Swift2Keychain

struct SavedPassword {
    static let service = "whitespace.co.uk"
    
    private static func stringFromData(possibleData: NSData?) -> String? {
        if let data = possibleData {
            return NSString(data: data,
                encoding: NSUTF8StringEncoding) as? String
        } else {
            return nil
        }
    }
    private static func dataFromString(string: String) -> NSData? {
        return string.dataUsingEncoding(NSUTF8StringEncoding)
    }
    
    static func deleteForUser(user: String) -> Bool {
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: user]
        
        let status = SecItemDelete(query)
        return status == noErr
    }
    
    static func setForUser(user: String, value: String) -> Bool {
        //delete
        deleteForUser(user)
        
        if value.length() == 0 {
            return true
        }
        guard let data = dataFromString(value) else {
            return false
        }
        //add
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: user,
            kSecAttrSynchronizable as String: kCFBooleanFalse,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        let status = SecItemAdd(query, nil)
        
        return status == noErr
    }
    static func getForUser(user: String) -> String? {
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: user,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecAttrSynchronizable as String: kSecAttrSynchronizableAny,
            kSecReturnData as String: kCFBooleanTrue as CFTypeRef,
        ]
        var result: AnyObject?
        
        let status = withUnsafeMutablePointer(&result) {
            SecItemCopyMatching(query, UnsafeMutablePointer($0))
        }
        
        if status == noErr {
            return stringFromData(result as? NSData)
        }
        
        return nil
    }
}