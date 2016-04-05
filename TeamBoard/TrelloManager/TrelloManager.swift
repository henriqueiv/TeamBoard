//
//  TrelloManager.swift
//  TeamBoard
//
//  Created by Henrique Valcanaia on 4/1/16.
//  Copyright © 2016 MC. All rights reserved.
//

import Foundation
import Parse

protocol TrelloManagerDelegate: class {
    
    func didAuthenticate()
    func didFailToAuthenticate()
    func didCreateAuthenticationOnServerWithId(id:String)
    func didFailToCreateAuthenticationOnServer()
    
}

class TrelloManager {
    
    weak var delegate: TrelloManagerDelegate?
    
    static let sharedInstance = TrelloManager()
    
    private(set) internal var token: String?
    
    func authenticate() {
        let obj = PFObject(className: "Authentication")
        obj.saveInBackgroundWithBlock { (suc:Bool, error:NSError?) in
            if error == nil {
                TrelloManager.sharedInstance.delegate?.didCreateAuthenticationOnServerWithId(obj.objectId!)
                self.checkForToken()
            } else {
                print("erro ao salvar obj authentication")
            }
        }
    }
    
    private func checkForToken() {
        let query = PFQuery(className: "Authentication")
        query.findObjectsInBackgroundWithBlock { (objs:[PFObject]?, error:NSError?) in
            if error == nil {
                if let authentication = objs?.first {
                    if let token = authentication["token"] as? String {
                        self.token = token
                        TrelloManager.sharedInstance.delegate?.didAuthenticate()
                    } else {
                        self.checkForToken()
                    }
                }
            } else {
                print("erro ao buscar authentication")
                TrelloManager.sharedInstance.delegate?.didFailToAuthenticate()
            }
        }
        
        
    }
    
}