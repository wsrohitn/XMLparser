//
//  ViewController.swift
//  XMLparser
//
//  Created by Rohit Natarajan on 08/03/2016.
//  Copyright © 2016 Rohit Natarajan. All rights reserved.
//

import UIKit

protocol CurrencyPickerParent {
    
    var currencyList: [String]{
        get
    }
    
    func setSelectedCurrency(currency : String)
}
class ViewController: UIViewController, NSXMLParserDelegate, UITableViewDataSource, CurrencyPickerParent {

    override func viewDidLoad() {
        print("hello world")
        super.viewDidLoad()
        title = baseCurrency
        tableView.dataSource = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Pick", style: .Plain, target: self, action: "pickCurrency")
        
        getRates()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func setSelectedCurrency(currency : String) {
        baseCurrency = currency
        getRates()
    }


    func pickCurrency(){
        print("pick currency")
        CurrencyPickerTVC.loadVC(self.storyboard!, nc: self.navigationController!, parent: self)
        print("new currency selected")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RateCell", forIndexPath: indexPath)
        print(indexPath)
        let item = myItems[indexPath.row]
        cell.textLabel?.text = item["targetCurrency"]
        cell.detailTextLabel?.text = item["exchangeRate"]
        return cell
    }

    var xmlParser : NSXMLParser?

    func getRates() {
        let urlString = NSURL(string: "http://www.floatrates.com/daily/\(baseCurrency).xml")
        let rssUrlRequest:NSURLRequest = NSURLRequest(URL:urlString!)
        myItems = []
        currencyList = []
        tableView.reloadData()
        let task = NSURLSession.sharedSession().dataTaskWithRequest(rssUrlRequest) {
            data, response, error in
            self.xmlParser = NSXMLParser(data: data!)
            self.xmlParser!.delegate = self
            self.xmlParser!.parse()
            print(self.myItems.count, "exchange rates")
            dispatch_async(dispatch_get_main_queue()){
                self.afterLoad()
            }
        }
        
        task.resume()
    }
    
    func afterLoad() {
        tableView.reloadData()
        title = "\(baseCurrency) against \(currencyList.count) currencies"
    }
    
    var currentKey = ""
    var baseCurrency = "GBP"
    var currencyList = [String]()
    /*class exchangeRateItem {
        var dict = [String:String]()
    }*/
    
    var currentItem: [String:String]?
    var myItems = [[String:String]]()
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        currentKey = elementName
        if currentKey == "item" {
            currentItem = [String:String]()
        }
        
    }
    
    @IBOutlet weak var tableView: UITableView!
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "item" {
            if let item = currentItem {
                myItems.append(item)
                currencyList.append(item["targetCurrency"]!)
                print(item["baseCurrency"]!, item["targetCurrency"]!, item["exchangeRate"]!, myItems.count)
                currentItem = nil
            }
        }
    }

    func parser(parser: NSXMLParser, foundCharacters string: String) {
        
        let trimmed = string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if currentItem != nil {
            if let _ = currentItem![currentKey]{
                currentItem![currentKey]! += trimmed
            }
            else {
                currentItem![currentKey] = trimmed
            }
        }
//        if var item = currentItem {
//            if let _ = item[currentKey]{
//                item[currentKey]! += trimmed
//            }
//            else {
//                item[currentKey] = trimmed
//            }
//            print("keys", currentItem!.count, item.count)
//        }
    }
    
    
   
}

