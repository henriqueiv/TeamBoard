//
//  TrelloManager.swift
//  TeamBoard
//
//  Created by Henrique Valcanaia on 4/1/16.
//  Copyright © 2016 MC. All rights reserved.
//

import Foundation
import Parse
import Alamofire

protocol TrelloManagerDelegate: class {
    
    func didAuthenticate()
    func didFailToAuthenticateWithError(error:NSError)
    func didCreateAuthenticationOnServerWithId(id:String)
    func didFailToCreateAuthenticationOnServer()
    
}

class TrelloManager {
    
    static let baseUrl = "https://api.trello.com/1/"
    static let appKeyParameterWithValue = "key=43611b805c9d34e882d8c802e3734678"
    
    typealias BoardCompletionHandler = (TBOBoard?,NSError?) -> Void
    typealias BoardsCompletionHandler = ([TBOBoard]?, NSError?) -> Void
    typealias MemberCompletionHandler = (TBOMember?, NSError?) -> Void
    typealias MembersCompletionHandler = ([TBOMember]?, NSError?) -> Void
    typealias ListsCompletionHandler = ([TBOList]?, NSError?) -> Void
    typealias OrganizationCompletionHandler = ([TBOOrganization]?, NSError?) -> Void
    
    
    weak var delegate: TrelloManagerDelegate?
    
    static let sharedInstance = TrelloManager()
    
    private let TokenUserDefaultsKey = "Token"
    private let CurrentUserIDUserDefaultsKey = "CurrentUser"
    
    private(set) internal var token: String? {
        get {
            let token = NSUserDefaults.standardUserDefaults().objectForKey(TokenUserDefaultsKey) as? String
            return token
        }
        
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: TokenUserDefaultsKey)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    private(set) internal var currentUserID: String? {
        get {
            let currentUserID = NSUserDefaults.standardUserDefaults().objectForKey(CurrentUserIDUserDefaultsKey) as? String
            return currentUserID
        }
        
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: CurrentUserIDUserDefaultsKey)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
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
            TrelloManager.sharedInstance.getMember { (me, error) in
                if error == nil {
                    TrelloManager.sharedInstance.delegate?.didFailToAuthenticateWithError(error!)
                } else {
                    TrelloManager.sharedInstance.delegate?.didAuthenticate()
                }
            }
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
    
    private func logOut() {
        token = ""
        currentUserID = ""
    }
    
    func getMember(completionHandler:MemberCompletionHandler?){
        if let token = token {
            let memberFromTokenUrl = TrelloManager.baseUrl+"token/\(token)/member?"+TrelloManager.appKeyParameterWithValue
            Alamofire.request(.GET, memberFromTokenUrl, parameters: nil)
                .responseJSON { response in
                    if (response.result.error == nil) {
                        let isSuccess = response.result.isSuccess
                        let jsonData = response.result.value as! [String : AnyObject]
                        if isSuccess {
                            let member = TBOMember(dictionary: jsonData)
                            self.currentUserID = member.id!
                            completionHandler?(member,nil)
                        }
                    }
                    else {
                        let serviceError = NSError(domain: "Service", code: 1, userInfo: nil)
                        completionHandler?(nil,serviceError)
                    }
            }
        }
        else {
            let serviceError = NSError(domain: "Service Token", code: 1, userInfo: nil)
            completionHandler?(nil,serviceError)
        }
    }
    
    func getOrganizations(completionHandler: OrganizationCompletionHandler?){
        if let token = token, memberID = currentUserID {
            let organizationUrl = TrelloManager.baseUrl+"members/\(memberID)/organizations?"+TrelloManager.appKeyParameterWithValue+"&token=\(token)"
            Alamofire.request(.GET, organizationUrl, parameters: nil)
                .responseJSON { response in
                    if (response.result.error == nil) {
                        let isSuccess = response.result.isSuccess
                        if isSuccess {
                            var organizations = [TBOOrganization]()
                            let jsonOrganizations = response.result.value as! [[String:AnyObject]]
                            for jsonOrganization in jsonOrganizations {
                                let organization = TBOOrganization(dictionary: jsonOrganization)
                                organizations.append(organization)
                            }
                            completionHandler?(organizations,nil)
                        }
                    }
                    else {
                        let serviceError = NSError(domain: "Service", code: 1, userInfo: nil)
                        completionHandler?(nil,serviceError)
                    }
            }
        }
        else {
            let serviceError = NSError(domain: "Service Token/User", code: 1, userInfo: nil)
            completionHandler?(nil,serviceError)
        }
    }
    
    func getBoards(organizationID:String,completionHandler: BoardsCompletionHandler?){
        if let token = token {
            let boardsURL = TrelloManager.baseUrl+"organizations/\(organizationID)/boards?"+TrelloManager.appKeyParameterWithValue
            Alamofire.request(.GET, boardsURL, parameters: ["token":token])
                .responseJSON { response in
                    if (response.result.error == nil) {
                        let isSuccess = response.result.isSuccess
                        if isSuccess {
                            var boards = [TBOBoard]()
                            let jsonBoards = response.result.value as! [[String : AnyObject]]
                            for jsonBoard in jsonBoards {
                                let board = TBOBoard(dictionary: jsonBoard)
                                boards.append(board)
                            }
                            completionHandler?(boards,nil)
                        }
                    }
                    else {
                        let serviceError = NSError(domain: "Service", code: 1, userInfo: nil)
                        completionHandler?(nil,serviceError)
                    }
            }
        }
        else {
            let serviceError = NSError(domain: "Service Token", code: 1, userInfo: nil)
            completionHandler?(nil,serviceError)
        }
    }
    
    func getBoard(boardID:String,completionHandler: BoardCompletionHandler?){
        if let token = token {
            let boardsURL = TrelloManager.baseUrl+"boards/\(boardID)?"+TrelloManager.appKeyParameterWithValue
            Alamofire.request(.GET, boardsURL, parameters: ["lists":"all","cards":"all","card_checklists":"all", "members":"all","token":token])
                .responseJSON { response in
                    if (response.result.error == nil) {
                        let isSuccess = response.result.isSuccess
                        if isSuccess {
                            let jsonBoard = response.result.value as! [String : AnyObject]
                            let board = TBOBoard(dictionary: jsonBoard)
                            completionHandler?(board,nil)
                        }
                    }
                    else {
                        let serviceError = NSError(domain: "Service", code: 1, userInfo: nil)
                        completionHandler?(nil,serviceError)
                    }
            }
        }
        else {
            let serviceError = NSError(domain: "Service Token", code: 1, userInfo: nil)
            completionHandler?(nil,serviceError)
        }
    }
    
    func getMembersFromBoard(boardID:String,completionHandler: MembersCompletionHandler?) {
        let membersFromBoardURL = TrelloManager.baseUrl+"boards/\(boardID)/members?"+TrelloManager.appKeyParameterWithValue+"&token=\(token!)"
        Alamofire.request(.GET, membersFromBoardURL, parameters: nil)
            .responseJSON { response in
                if (response.result.error == nil) {
                    let jsonData = response.result.value as! [String : AnyObject]
                    if jsonData["Success"] != nil {
                        var members = [TBOMember]()
                        let jsonMembers = jsonData["members"] as! [[String: AnyObject]]
                        for jsonMember in jsonMembers {
                            let member = TBOMember(dictionary: jsonMember)
                            members.append(member)
                        }
                        completionHandler?(members,nil)
                    }
                }
                else {
                    let serviceError = NSError(domain: "Service", code: 1, userInfo: nil)
                    completionHandler?(nil,serviceError)
                }
        }
    }
    
    func getLists(boardID:String,completionHandler:ListsCompletionHandler?) {
        let membersFromBoardURL = TrelloManager.baseUrl+"boards/\(boardID)/lists?"+TrelloManager.appKeyParameterWithValue+"&token=\(token!)"
        Alamofire.request(.GET, membersFromBoardURL, parameters: nil)
            .responseJSON { response in
                if (response.result.error == nil) {
                    let jsonData = response.result.value as! [String : AnyObject]
                    if jsonData["Success"] != nil {
                        var lists = [TBOList]()
                        let jsonLists = jsonData["lists"] as! [[String: AnyObject]]
                        for jsonList in jsonLists {
                            let list = TBOList(dictionary: jsonList)
                            lists.append(list)
                        }
                        completionHandler?(lists,nil)
                    }
                }
                else {
                    let serviceError = NSError(domain: "Service", code: 1, userInfo: nil)
                    completionHandler?(nil,serviceError)
                }
        }
    }
    
    
}






