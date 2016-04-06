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
    func didFailToAuthenticateWithError(error:NSError)
    func didCreateAuthenticationOnServerWithId(id:String)
    func didFailToCreateAuthenticationOnServer()
    
}

class TrelloManager {
    
    weak var delegate: TrelloManagerDelegate?
    
    static let sharedInstance = TrelloManager()
    
    private(set) internal var token: String?
    
    private let CheckTokenLimitAttempts = 1500
    
    private var checkTokenAttempts = 0
    private var cancelTokenCheck = false
    
    //    private queue:NSQueue
    
    func authenticate() {
        self.checkTokenAttempts = 0
        let authentication = TBAuthentication()
        authentication.saveInBackgroundWithBlock { (suc:Bool, error:NSError?) in
            if error == nil {
                let authenticationId = authentication.objectId!
                TrelloManager.sharedInstance.delegate?.didCreateAuthenticationOnServerWithId(authenticationId)
                self.checkForTokenWithAuthenticationId(authenticationId)
            } else {
                print("Error trying to save authentication!")
            }
        }
    }
    
    // TODO: Simplify and remove duplicated code
    private func checkForTokenWithAuthenticationId(id:String) {
        if let query = TBAuthentication.query() {
            query.getObjectInBackgroundWithId(id) { (obj:PFObject?, error:NSError?) in
                self.checkTokenAttempts += 1
                let shouldStop = (self.checkTokenAttempts >= self.CheckTokenLimitAttempts) || self.cancelTokenCheck
                if shouldStop {
                    self.handleAuthenticationAsPFObject(obj!)
                } else {
                    if error == nil {
                        if obj == nil {
                            // Object not found, check again
                            self.checkForTokenWithAuthenticationId(id)
                        } else {
                            // Object found, check token
                            self.handleAuthenticationAsPFObject(obj!)
                        }
                    } else {
                        print("Error trying to get Authentication with id \(id)")
                        TrelloManager.sharedInstance.delegate?.didFailToAuthenticateWithError(error!)
                    }
                }
            }
        }
    }
    
    private func handleAuthenticationAsPFObject(obj:PFObject) {
        if let token = obj["token"] as? String where !token.isEmpty {
            self.token = token
            obj.deleteInBackgroundWithBlock(self.deleteAuthentication)
            TrelloManager.sharedInstance.delegate?.didAuthenticate()
        } else {
            print("Empty token for Authorization(id: \(obj.objectId!))")
            self.checkForTokenWithAuthenticationId(obj.objectId!)
        }
    }
    
    private func deleteAuthentication(suc:Bool, error:NSError?) {
        if error == nil {
            print("Authentication deleted")
        } else {
            print("Error while deleting authentication: \(error!)")
        }
    }
    
}






