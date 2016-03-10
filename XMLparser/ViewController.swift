//
//  ViewController.swift
//  XMLparser
//
//  Created by Rohit Natarajan on 08/03/2016.
//  Copyright © 2016 Rohit Natarajan. All rights reserved.
//

import UIKit
import WsBase

protocol CurrencyPickerParent {
    
    var currencyList: [String]{
        get
    }
    
    var favourites: [String]{
        get
    }

    func setSelectedCurrency(currency : String)
}

class ViewController: UIViewController, NSXMLParserDelegate, UITableViewDataSource, UITableViewDelegate, CurrencyPickerParent {

    var favourites = [String]()
    var xmlParser : NSXMLParser?
    var currentKey = ""
    var baseCurrency = "GBP"
    var currencyList = [String]()
    var currentItem: exchangeRateItem?
    var myItems = [exchangeRateItem]()
    var myFavourites = [exchangeRateItem]()
    var headerFinished = false
    var header = xmlHeader()
    
    class exchangeRateItem {
        var targetCurrency = ""
        var exchangeRate = ""
    }
    
    class xmlHeader {
        var pubDate = ""
        var lastBuildDate = ""
        var title = ""
        var link = ""
    }
    
    @IBOutlet weak var myButton: UIButton!
    
    @IBAction func actionButton(sender: UIButton) {
        UIFuncs.showMessage(self, "Info", "Published Date: \n \(header.pubDate) \n\n URL:\n \(header.link)")
        return
    }
    
    override func viewDidLoad() {
       // self.navigationController?.navigationBar.translucent = false
        super.viewDidLoad()
        
        
        //UIBranding.sharedInstance.branding = makeMustang1944()
        
        UIBranding.fixView(self.view!)
        UIBranding.fixTableView(tableView)
        
        baseCurrency = Preferences.readString(Preferences.Id.baseCurrency, defaultValue: "USD")
        let csv = Preferences.readString(Preferences.Id.favourites)
        
        for x in csv.componentsSeparatedByString(",") {
            if x != "" {
                favourites.append(x)
            }
        }
        
        myButton.setTitle("Info", forState: .Normal)
        title = baseCurrency
        tableView.dataSource = self
        tableView.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Pick", style: .Plain, target: self, action: "pickCurrency")
        
        getRates()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    func makeMustang1944() -> WsBranding {
        let branding = WsBranding()
        branding.backgroundColor = Funcs.makeColour(38,38,38)
        branding.backgroundColor2 = Funcs.makeColour(41,49,70)
        branding.backgroundSelectedColor = Funcs.makeColour(41,49,70)
        branding.titleColor = Funcs.makeColour(128,137,160)
        branding.subtitleColor = Funcs.makeColour(222,222,222)
        branding.buttonColor = Funcs.makeColour(233,156,55)
        
        return branding
    }
    
    func makeDolores() -> WsBranding{
        let branding = WsBranding()
        branding.backgroundColor = Funcs.makeColour(231,229,159)
        branding.backgroundColor2 = Funcs.makeColour(202,170,67)
        branding.backgroundSelectedColor = Funcs.makeColour(202,170,67)
        branding.titleColor = Funcs.makeColour(71,97,122)
        branding.subtitleColor = Funcs.makeColour(42,56,61)
        branding.buttonColor = Funcs.makeColour(0,0,0)
        
        return branding
    }
    
    func setSelectedCurrency(currency : String) {
        baseCurrency = currency
        Preferences.writeString(Preferences.Id.baseCurrency, value: baseCurrency)
        getRates()
    }
    
    func pickCurrency(){        
        currencyList.sortInPlace()
        //CurrencyPickerCVC.loadVC(self.storyboard!, nc: self.navigationController!, parent: self)
        performSegueWithIdentifier("toCurrencyPickerCVC", sender: self)
        print("new currency selected")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toCurrencyPickerCVC" {
            let dvc = segue.destinationViewController as! CurrencyPickerCVC
            dvc.parent = self
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return myFavourites.count
        }
        return myItems.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "\(myFavourites.count) Favourites"
        }
        return "\(myItems.count) Others"
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RateCell", forIndexPath: indexPath)
        UIBranding.fixTableViewCell(cell)
        cell.accessoryType = UITableViewCellAccessoryType.DetailButton
        let item = getItem(indexPath)
        cell.textLabel?.text = item.targetCurrency
        cell.detailTextLabel?.text = item.exchangeRate
        return cell
    }
    
    func getItem(indexPath: NSIndexPath) -> exchangeRateItem {
        if indexPath.section == 0 {
            return myFavourites[indexPath.row]
        }
        return myItems[indexPath.row]
    }

    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        let item = getItem(indexPath)
        let currency = item.targetCurrency
        if let index = favourites.indexOf(currency) {
            favourites.removeAtIndex(index)
            removeFavourite(currency)
        } else {
            favourites.append(currency)
            makeFavourite(currency)
        }
        
        print(favourites)
        Preferences.writeString(Preferences.Id.favourites, value: favourites.joinWithSeparator(","))
        tableView.reloadData()
    }
    
    func makeFavourite(currency: String) {
        for index in 0 ..< myItems.count {
            let item = myItems[index]
            if item.targetCurrency == currency {
                myItems.removeAtIndex(index)
                myFavourites.append(item)
                return
            }
        }
    }
    
    func removeFavourite(currency: String) {
        for index in 0 ..< myFavourites.count {
            let item = myFavourites[index]
            if item.targetCurrency == currency {
                myFavourites.removeAtIndex(index)
                myItems.append(item)
                return
            }
        }
    }
    
    func getRates() {
        let urlString = NSURL(string: "http://www.floatrates.com/daily/\(baseCurrency).xml")
        let rssUrlRequest:NSURLRequest = NSURLRequest(URL:urlString!)
        myItems = []
        myFavourites = []
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
        myItems.sortInPlace {
            $0.targetCurrency < $1.targetCurrency
        }
        myFavourites.sortInPlace {
            $0.targetCurrency < $1.targetCurrency
        }
        tableView.reloadData()
        title = "\(baseCurrency) against \(currencyList.count) currencies"
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        currentKey = elementName
        if currentKey == "item" {
            currentItem = exchangeRateItem()
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "item" {
            if let item = currentItem {
                if favourites.contains(item.targetCurrency) {
                    myFavourites.append(item)
                }
                else {
                    myItems.append(item)
                }
                currencyList.append(item.targetCurrency)
                print(item.targetCurrency, item.exchangeRate, myItems.count)
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
                print("pubdate")
                header.pubDate += trimmed
            }
            if currentKey == "lastBuildDate" {
                header.lastBuildDate += trimmed
                headerFinished = true
            }
            if currentKey == "link" {
                header.link += trimmed
            }
            if currentKey == "title" {
                header.title += trimmed
            }
        }
    }
}

