//
//  Parser.swift
//  XMLparser
//
//  Created by Rohit Natarajan on 11/03/2016.
//  Copyright © 2016 Rohit Natarajan. All rights reserved.
//

import Foundation
import WsBase



class Parser: NSObject, NSXMLParserDelegate {
    
    var xmlParser : NSXMLParser?
    var currentKey = ""
    var baseCurrency = "GBP"
    var currentItem: ExchangeRateItem?
    var myItems = [ExchangeRateItem]()
    var headerFinished = false
    var header = ExchangeRateHeader()
    
    class func make(data: NSData) -> Parser {
        let p = Parser()
        p.xmlParser = NSXMLParser(data: data)
        p.xmlParser?.delegate = p
        p.xmlParser?.parse()
        return p
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        currentKey = elementName
        if currentKey == "item" {
            currentItem = ExchangeRateItem()
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "item" {
            if let item = currentItem {
                myItems.append(item)
                print(myItems.last?.targetCurrency)
                
                currentItem = nil
            }
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        
        let trimmed = string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if let item = currentItem {
            if currentKey == "targetCurrency" {
                item.targetCurrency += trimmed
            }
            
            if currentKey == "exchangeRate" {
                item.exchangeRate += trimmed
            }
        }
        
        if headerFinished == false {
            if currentKey == "pubDate" {
                header.pubDate += trimmed
                headerFinished = true
            }
            if currentKey == "link" {
                header.link += trimmed
            }
        }
    }
}