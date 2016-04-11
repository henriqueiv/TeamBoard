//
//  AppDelegate.swift
//  TeamBoard
//
//  Created by Henrique Valcanaia on 3/31/16.
//  Copyright © 2016 MC. All rights reserved.
//

import Parse
import UIKit

enum StoryboardName: String, CustomStringConvertible {
    case Login
    case CompanyRanking
    case OrganizationSelection
    
    var description: String {
        return self.rawValue
    }
}



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    private let ParseApplicationID = "Q7fNAQmc6l7aFPm36u97w6SWPLbVFmEmw0q9Fnt5"
    private let ParseClientKey = "71wrEeeiRT8SVkPeeFC4mB8oFnyuOio5mMD3aB9Q"
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        configureParse(launchOptions)
        initApp()
        
        return true
    }
    
    // MARK: - Private helpers
    private func configureParse(launchOptions: [NSObject: AnyObject]?){
        TBAuthentication.registerSubclass()
        
        Parse.setApplicationId(ParseApplicationID, clientKey: ParseClientKey)
        PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions, block: { (success: Bool, error: NSError?) -> Void in
            if error != nil {
                print(error?.description)
            }
        })
        
    }
    
    private func initApp() {
        if TrelloManager.sharedInstance.token.isEmpty {
            gotoStoryboardWithName(.Login)
        } else {
            gotoStoryboardWithName(.OrganizationSelection)
        }
        //   gotoStoryboard(StoryboardName.CompanyRanking.rawValue)
    }
    
    func gotoStoryboardWithName(storyboardName:StoryboardName){
        let sb = UIStoryboard(name: storyboardName.rawValue, bundle: nil)
        let vc = sb.instantiateInitialViewController()
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }
}

