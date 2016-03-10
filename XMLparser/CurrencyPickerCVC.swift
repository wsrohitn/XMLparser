//
//  CurrencyPickerCVC.swift
//  XMLparser
//
//  Created by Rohit Natarajan on 09/03/2016.
//  Copyright © 2016 Rohit Natarajan. All rights reserved.
//

import UIKit
import WsBase

class CurrencyPickerCVC: UICollectionViewController {
    
    class func loadVC(sb:UIStoryboard, nc:UINavigationController, parent: CurrencyPickerParent) {
        if let vc = sb.instantiateViewControllerWithIdentifier("CurrencyPickerCVC") as? CurrencyPickerCVC {
            vc.setInitialState(parent)
            nc.pushViewController(vc, animated: true)
        }
    }
    
    var parent: CurrencyPickerParent?
    
    func setInitialState(parent: CurrencyPickerParent) {
        self.parent = parent
        self.title = "Choose from \(parent.currencyList.count) currencies"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIBranding.fixCollectionView(collectionView!)
        //self.navigationController?.navigationBar.translucent = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return parent!.currencyList.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CurrencyPickerCell.getReuseIdentifier(), forIndexPath: indexPath) as! CurrencyPickerCell
        
        if let btn = cell.btn {
            var currency = parent!.currencyList[indexPath.row]
            btn.setTitle(currency, forState: .Normal)
            UIBranding.fixButton(btn)
            if parent!.favourites.contains(currency) {
                cell.backgroundColor = UIBranding.sharedInstance.branding.backgroundSelectedColor
            } else {
                cell.backgroundColor = UIColor.clearColor()
            }
        }
        return cell
    }
    
    @IBAction func clickCurrency(sender: AnyObject) {
        if let btn = sender as? UIButton, let lbl = btn.titleLabel {
            parent!.setSelectedCurrency(lbl.text!)
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
}