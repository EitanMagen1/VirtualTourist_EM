//
//  error handeling.swift
//  OnTheMap-EM1
//
//  Created by Lauren Efron on 18/01/2016.
//  Copyright © 2016 Udacity. All rights reserved.
//

import UIKit

extension UIViewController{
    func presentError(alertString: String){
        let ac = UIAlertController(title: "Error", message: alertString, preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
        self.presentViewController(ac, animated: true, completion: nil)
        
        
    }
}