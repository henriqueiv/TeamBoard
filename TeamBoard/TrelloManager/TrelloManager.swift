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
    
    static let baseUrl = "https://api.trello.com/1/"
    static let appKeyParameterWithValue = "key=43611b805c9d34e882d8c802e3734678"
    
    typealias boardsCompletionHandler = ([TBOBoard]?,NSError?)->Void
    typealias membersCompletionHandler = ([TBOMember]?,NSError?)->Void
    typealias listsCompletionHandler = ([TBOList]?,NSError?)->Void
    
    
    
    weak var delegate: TrelloManagerDelegate?
    
    static let sharedInstance = TrelloManager()
    
    private(set) internal var token: String?
    
    func authenticate() {
        let obj = TBAuthentication()
        obj.saveInBackgroundWithBlock { (suc:Bool, error:NSError?) in
            if error == nil {
                TrelloManager.sharedInstance.delegate?.didCreateAuthenticationOnServerWithId(obj.objectId!)
                self.checkForTokenWithId(obj.objectId!)
            } else {
                print("erro ao salvar obj authentication")
            }
        }
    }
    
    private func checkForTokenWithId(id:String) {
        if let query = TBAuthentication.query() {
            query.getFirstObjectInBackgroundWithBlock({ (obj:PFObject?, error:NSError?) in
                if error == nil {
                    if obj == nil {
                        self.checkForTokenWithId(id)
                    } else {
                        if let authentication = obj as? TBAuthentication {
                            if authentication.token.isEmpty {
                                self.checkForTokenWithId(id)
                            } else {
                                self.token = authentication.token
                                authentication.deleteInBackgroundWithBlock({ (suc:Bool, error:NSError?) in
                                    if error == nil {
                                        print("deletou authentication")
                                    } else {
                                        print(error)
                                    }
                                })
                                TrelloManager.sharedInstance.delegate?.didAuthenticate()
                            }
                        }
                    }
                } else {
                    print("erro ao buscar authentication")
                    TrelloManager.sharedInstance.delegate?.didFailToAuthenticateWithError(error!)
                }
            })
        }
        
    }
    
}