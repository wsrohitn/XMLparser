//
//  LoginAlert.swift
//  Clearance
//
//  Created by David on 02/03/2015.
//  Copyright (c) 2015 Jonathan Clarke. All rights reserved.
//

import UIKit

class LoginAlert {
    
    class func showLoginDialogForParent(parent: UIViewController, thenCallback callback: (isOK: Bool) -> ()) {
        let controller = UIAlertController(title: "Log In", message: "Enter your user name and password.", preferredStyle: UIAlertControllerStyle.Alert)
        let login_action = UIAlertAction(title: "Login", style: .Default) { (_) in
            let user_name_field = controller.textFields![0]
            let password_field = controller.textFields![1]
            
            Login.sharedInstance.userName = user_name_field.text
            Login.sharedInstance.password = password_field.text
            dispatch_async(dispatch_get_main_queue()) {
                Login.sharedInstance.validateAndCallback(callback)
            }
        }
        login_action.enabled = (Login.sharedInstance.userName != nil)
        let cancel_action = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in
            callback(isOK: false)
        }
        
        controller.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "User name"
            if let old_name = Login.sharedInstance.userName {
                textField.text = old_name
            }
            
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
                if let s = textField.text {
                    login_action.enabled = !s.isEmpty
                }
                else {
                    login_action.enabled = false
                }
            }
        }
        controller.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Password"
            textField.secureTextEntry = true
        }
        controller.addAction(login_action)
        controller.addAction(cancel_action)
        
        parent.presentViewController(controller, animated: true, completion: { [weak controller] in
            if let _ = Login.sharedInstance.userName {
                controller?.textFields?[1].becomeFirstResponder()
            }
            })
    }
}