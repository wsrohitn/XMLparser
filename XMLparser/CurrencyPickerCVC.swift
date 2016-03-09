//
//  CurrencyPickerCVC.swift
//  XMLparser
//
//  Created by Rohit Natarajan on 09/03/2016.
//  Copyright © 2016 Rohit Natarajan. All rights reserved.
//

import UIKit

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
            btn.setTitle(parent!.currencyList[indexPath.row], forState: .Normal)
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