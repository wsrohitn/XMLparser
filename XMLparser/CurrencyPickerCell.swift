//
//  CurrencyPickerCell.swift
//  XMLparser
//
//  Created by Rohit Natarajan on 09/03/2016.
//  Copyright © 2016 Rohit Natarajan. All rights reserved.
//

import UIKit

class CurrencyPickerCell: UICollectionViewCell {
    
    @IBOutlet weak var lblCurrency: UILabel!
    @IBOutlet weak var btn: UIButton!
    
    func setLabel(string:String) {
        self.lblCurrency.text = string
    }
    
    class func getReuseIdentifier() -> String {
        return String(self)
    }
}
