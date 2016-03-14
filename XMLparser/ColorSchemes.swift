//
//  ColorSchemes.swift
//  XMLparser
//
//  Created by Rohit Natarajan on 11/03/2016.
//  Copyright © 2016 Rohit Natarajan. All rights reserved.
//

import Foundation
import WsBase

class ColorSchemes {
  
    class func makeMustang1944() -> WsBranding {
        let branding = WsBranding()
        branding.backgroundColor = Funcs.makeColour(38,38,38)
        branding.backgroundColor2 = Funcs.makeColour(41,49,70)
        branding.backgroundSelectedColor = Funcs.makeColour(41,49,70)
        branding.titleColor = Funcs.makeColour(128,137,160)
        branding.subtitleColor = Funcs.makeColour(222,222,222)
        branding.buttonColor = Funcs.makeColour(233,156,55)
        
        return branding
    }
    
    class func makeDolores() -> WsBranding {
        let branding = WsBranding()
        branding.backgroundColor = Funcs.makeColour(231,229,159)
        branding.backgroundColor2 = Funcs.makeColour(202,170,67)
        branding.backgroundSelectedColor = Funcs.makeColour(202,170,67)
        branding.titleColor = Funcs.makeColour(71,97,122)
        branding.subtitleColor = Funcs.makeColour(42,56,61)
        branding.buttonColor = Funcs.makeColour(0,0,0)
        
        return branding
    }
}