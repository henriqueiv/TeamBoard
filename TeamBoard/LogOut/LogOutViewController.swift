//
//  LogOutViewController.swift
//  TeamBoard
//
//  Created by Henrique Valcanaia on 4/10/16.
//  Copyright © 2016 MC. All rights reserved.
//

import UIKit

class LogOutViewController: UIViewController {
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        logOut()
    }
    
    private func logOut() {
        TrelloManager.sharedInstance.logOut()
        let sb = UIStoryboard(name: StoryboardName.Login.rawValue, bundle: nil)
        let vc = sb.instantiateInitialViewController()
        presentViewController(vc!, animated: true, completion: nil)
    }
    
}
