//
//  ViewController.swift
//  XMLparser
//
//  Created by Rohit Natarajan on 08/03/2016.
//  Copyright © 2016 Rohit Natarajan. All rights reserved.
//

import UIKit
import WsBase
import WsCouchBasic

protocol CurrencyPickerParent {
    
    var currencyList: [String]{
        get
    }
    
    var favourites: [String]{
        get
    }
    
    func setSelectedCurrency(currency : String)
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CurrencyPickerParent {

    var baseCurrency = "GBP"
    var currencyList = [String]()
    var myFavourites = [ExchangeRateItem]()
    var actionMessage = "Not filled in yet."
    var favourites = [String]()
    var myItems = [ExchangeRateItem]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var myButton: UIButton!
    @IBAction func actionButton(sender: UIButton) {
        UIFuncs.showMessage(self, "Info", actionMessage)
        return
    }
    @IBAction func refresh(sender: AnyObject) {
        getRates()
    }    
    @IBAction func usageButtonAction(sender: AnyObject) {
        performSegueWithIdentifier("toUsageButtonTVC", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toCurrencyPickerCVC" {
            let dvc = segue.destinationViewController as! CurrencyPickerCVC
            dvc.parent = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        Login.sharedInstance.setCBSettings( CBSettings.sharedInstance )
        if Login.sharedInstance.isValid {            
            afterLogin()
        } else {
            self.view.userInteractionEnabled = false
            doLogin()
        }
    }
    
    func afterLogin() {
        
        CBSettings.sharedInstance.setCredentials( Login.sharedInstance.userName, password : Login.sharedInstance.password )
        print("afterLogin", CBSettings.sharedInstance.userName, CBSettings.sharedInstance.password )
        
        SyncManager.sharedInstance.startContinuousReplication(withSettings: CBSettings.sharedInstance)
        getRates()
        if let db = SyncManager.sharedInstance.database {
            print("got ourselves a database")
        } else {
            print("no database")
        }
    }
    
    func doLogin() {
        LoginAlert.showLoginDialogForParent(self, thenCallback: { (isOK: Bool) in
            if isOK {
                self.view.userInteractionEnabled = true
                
                self.afterLogin()
            }
            else {
                self.view.userInteractionEnabled = false
                self.doLogin()
            }
        })
    }
    
    func setSelectedCurrency(currency : String) {
        baseCurrency = currency
        Preferences.writeString(Preferences.Id.baseCurrency, value: baseCurrency)
        getRates()
    }
    
    func pickCurrency(){
        print("sorting currency list")
        currencyList.sortInPlace()
        CurrencyPickerCVC.loadVC(self.storyboard!, nc: self.navigationController!, parent: self)
        print("new currency selected")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    func getItem(indexPath: NSIndexPath) -> ExchangeRateItem {
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
                sortMyItems()
                return
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.contentInset = UIEdgeInsetsZero
    }
    
    func getRates() {
        let urlString = NSURL(string: "http://www.floatrates.com/daily/\(baseCurrency).xml")
        let rssUrlRequest:NSURLRequest = NSURLRequest(URL:urlString!)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(rssUrlRequest) {
            data, response, error in
            if error?.code == NSURLErrorNotConnectedToInternet {
                dispatch_async(dispatch_get_main_queue()){
                    UIFuncs.showMessage(self, "Error", "Not connected to the internet")
                }
            } else {
                let p = Parser.make(data!)
                dispatch_async(dispatch_get_main_queue()){
                    print(p.myItems.count, "items in p")
                    self.afterLoad(p.myItems, header: p.header)
                }
            }
        }
        task.resume()
    }
    
    func sortMyItems() {
        myItems.sortInPlace {
            $0.targetCurrency < $1.targetCurrency
        }
        myFavourites.sortInPlace {
            $0.targetCurrency < $1.targetCurrency
        }
    }
    
    func afterLoad(items: [ExchangeRateItem], header: ExchangeRateHeader) {
        myItems = []
        myFavourites = []
        currencyList = []
        actionMessage = "\(header.pubDate), \(header.link)"
        for item in items {
            currencyList.append(item.targetCurrency)
            if favourites.contains(item.targetCurrency) {
                myFavourites.append(item)
            } else {
                myItems.append(item)
            }
        }
        
        sortMyItems()
        tableView.reloadData()
        title = "\(baseCurrency) against \(currencyList.count) currencies"
        saveToCouchBase()
    }
    
    func saveToCouchBase(){
        var dict = StringKeyDict()
        var array = [StringKeyDict]()
        
        for f in myFavourites {
            array.append(f.makeDict())
        }
        
        dict["createdAt"] = TimeStamper.createLocalTimeStamp()
        dict["userName"] = CBSettings.sharedInstance.userName
        dict["baseCurrency"] = baseCurrency
        dict["myFavourites"] = array
        dict["favourites"] = favourites
        dict["type"] = "exchangeRates"
        dict["channels"] = ["exchangeRates"]
        
        if let db = SyncManager.sharedInstance.database {
            
            let timeStamp = TimeStamper.createYYYYMMDD_HHMMSS()
            if let doc = db.documentWithID("ExchangeRates_\(baseCurrency)_\(timeStamp)") {
              
                do {
                    try doc.putProperties(dict)
                    print("Saved", doc.documentID)
                } catch {
                    print(error)
                }
            }
        }
        else {
            print("no database")
        }
    }
}

