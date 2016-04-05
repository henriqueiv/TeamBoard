//
//  AppDelegate.swift
//  TeamBoard
//
//  Created by Henrique Valcanaia on 3/31/16.
//  Copyright © 2016 MC. All rights reserved.
//

import Parse
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    let kParseApplicationID = "Q7fNAQmc6l7aFPm36u97w6SWPLbVFmEmw0q9Fnt5"
    let kParseClientKey = "71wrEeeiRT8SVkPeeFC4mB8oFnyuOio5mMD3aB9Q"
    
    func configureParse(launchOptions: [NSObject: AnyObject]?){
        Parse.setApplicationId(kParseApplicationID, clientKey: kParseClientKey)
        PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions, block: { (success: Bool, error: NSError?) -> Void in
            if error != nil {
                print(error?.description)
            }
        })
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        configureParse(launchOptions)
        
        
        return true
    }
    
}

