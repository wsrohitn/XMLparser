//
//  CurrencyPickerTVC.swift
//  XMLparser
//
//  Created by Rohit Natarajan on 08/03/2016.
//  Copyright © 2016 Rohit Natarajan. All rights reserved.
//

import UIKit
import WsBase
import WsCouchBasic

class UsageRecord
{
    var userName : String
    var createdAt : String
    var baseCurrency : String
    init( userName : String, createdAt : String, baseCurrency : String )
    {
        self.userName = userName
        self.createdAt = createdAt
        self.baseCurrency = baseCurrency
    }
}

class UsageButtonTVC: UITableViewController, CBLiveQueryObserverDelegate {
    
    var myItems = [UsageRecord]()
    
    var myObserver: CBLiveQueryObserver?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialiseQuery()
            
        UIBranding.fixTableView(tableView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myItems.count
    }

    func initialiseQuery() {
        
        if let query = SyncManager.sharedInstance.createQuery(forViewNamed: "ExchangeRatesView") {
            query.descending = true
            myObserver = CBLiveQueryObserver(forQuery: query)
            myObserver!.delegate = self
        }
        
    }
    
    func liveQueryObserverHasRows(rows: CBLQueryEnumerator) {
        var items = [UsageRecord]()
        for cbRow in rows.rows {
            print(cbRow)
            
            if let dict = cbRow.value as? StringKeyDict {
                let item = UsageRecord(userName: dict.getString("userName"), createdAt: dict.getString("createdAt"), baseCurrency: dict.getString("baseCurrency"))
                items.append(item)
            }
        }
        
        myItems = items
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UsageCell", forIndexPath: indexPath)

        UIBranding.fixTableViewCell( cell )
        let item = myItems[ indexPath.row ]
        
        cell.textLabel?.text = item.createdAt
        cell.detailTextLabel?.text = "\(item.userName) looked at \(item.baseCurrency)"

        return cell
    }

    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print( "selected", indexPath)
    }

}
