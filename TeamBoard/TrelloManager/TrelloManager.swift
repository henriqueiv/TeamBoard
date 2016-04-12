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
    static let appKey = "43611b805c9d34e882d8c802e3734678"
    
    typealias BoardCompletionHandler = (TBOBoard?,NSError?) -> Void
    typealias BoardsCompletionHandler = ([TBOBoard]?, NSError?) -> Void
    typealias CardsCompletionHandler = ([TBOCard]?, NSError?) -> Void
    typealias MemberCompletionHandler = (TBOMember?, NSError?) -> Void
    typealias MembersCompletionHandler = ([TBOMember]?, NSError?) -> Void
    typealias ListsCompletionHandler = ([TBOList]?, NSError?) -> Void
    typealias OrganizationCompletionHandler = ([TBOOrganization]?, NSError?) -> Void
    
    
    weak var delegate: TrelloManagerDelegate?
    
    static let sharedInstance = TrelloManager()
    
    private let TokenUserDefaultsKey = "Token"
    private let CurrentUserIDUserDefaultsKey = "CurrentUser"
    
    private(set) internal var token: String {
        get {
            if let testToken = (NSProcessInfo.processInfo().environment["token"]) {
                return testToken
            } else {
                let token = NSUserDefaults.standardUserDefaults().objectForKey(TokenUserDefaultsKey) as? String
                return token ?? ""
            }
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
    
    var member:TBOMember?
    
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
                    TrelloManager.sharedInstance.delegate?.didAuthenticate()
                } else {
                    TrelloManager.sharedInstance.delegate?.didFailToAuthenticateWithError(error!)
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
    
    func logOut() {
        token = ""
        currentUserID = ""
    }
    
    func getMember(completionHandler:MemberCompletionHandler?){
        if !token.isEmpty {
            let memberFromTokenUrl = TrelloManager.baseUrl+"token/\(token)/member?"
            Alamofire.request(.GET, memberFromTokenUrl, parameters: ["key":TrelloManager.appKey,"token":token])
                .responseJSON { response in
                    if (response.result.error == nil) {
                        let isSuccess = response.result.isSuccess
                        let jsonData = response.result.value as! [String : AnyObject]
                        if isSuccess {
                            let member = TBOMember(dictionary: jsonData)
                            self.currentUserID = member.id!
                            self.member = member
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
        if !token.isEmpty, let memberID = currentUserID {
            let organizationUrl = TrelloManager.baseUrl+"members/\(memberID)/organizations?"
            Alamofire.request(.GET, organizationUrl, parameters: ["key":TrelloManager.appKey,"token":token])
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
        if !token.isEmpty {
            let boardsURL = TrelloManager.baseUrl+"organizations/\(organizationID)/boards?"
            Alamofire.request(.GET, boardsURL, parameters: ["key":TrelloManager.appKey,"token":token])
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
    
    // FIXME: for some reason it is not returning cards.
    //        Use getCardsFromBoard to fetch board cards.
    func getBoard(boardID:String,completionHandler: BoardCompletionHandler?){
        if !token.isEmpty {
            let boardsURL = TrelloManager.baseUrl+"boards/\(boardID)?"
            let parms = ["lists":"all","cards":"all","card_checklists":"all", "members":"all","key":TrelloManager.appKey,"token":token]
            Alamofire.request(.GET, boardsURL, parameters: parms)
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
    
    func getCardsFromBoard(boardID:String,completionHandler: CardsCompletionHandler?){
        if !token.isEmpty {
            let boardsURL = TrelloManager.baseUrl+"boards/\(boardID)/cards?"
            Alamofire.request(.GET, boardsURL, parameters: ["checklists":"all","members":"true","key":TrelloManager.appKey,"token":token])
                .responseJSON { response in
                    if (response.result.error == nil) {
                        let isSuccess = response.result.isSuccess
                        if isSuccess {
                            var cards = [TBOCard]()
                            let jsonCards = response.result.value as! [[String : AnyObject]]
                            for jsonCard in jsonCards {
                                let card = TBOCard(dictionary: jsonCard)
                                cards.append(card)
                            }
                            completionHandler?(cards,nil)
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
    
//    func getMembersFromBoard(boardID:String,completionHandler: MembersCompletionHandler?) {
//        if let token = token {
//            let membersFromBoardURL = TrelloManager.baseUrl+"boards/\(boardID)/members?"
//            Alamofire.request(.GET, membersFromBoardURL, parameters: ["key":TrelloManager.appKey,"token":token])
//                .responseJSON { response in
//                    if (response.result.error == nil) {
//                        let jsonData = response.result.value as! [String : AnyObject]
//                        if jsonData["Success"] != nil {
//                            var members = [TBOMember]()
//                            let jsonMembers = jsonData["members"] as! [[String: AnyObject]]
//                            for jsonMember in jsonMembers {
//                                let member = TBOMember(dictionary: jsonMember)
//                                members.append(member)
//                            }
//                            completionHandler?(members,nil)
//                        }
//                    }
//                    else {
//                        let serviceError = NSError(domain: "Service", code: 1, userInfo: nil)
//                        completionHandler?(nil,serviceError)
//                    }
//            }
//        }
//        else {
//            let serviceError = NSError(domain: "Service Token", code: 1, userInfo: nil)
//            completionHandler?(nil,serviceError)
//        }
//    }
    
    func getLists(boardID:String,completionHandler:ListsCompletionHandler?) {
        if !token.isEmpty {
            let membersFromBoardURL = TrelloManager.baseUrl+"boards/\(boardID)/lists?"
            Alamofire.request(.GET, membersFromBoardURL, parameters: ["key":TrelloManager.appKey,"token":token])
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
        else {
            let serviceError = NSError(domain: "Service Token", code: 1, userInfo: nil)
            completionHandler?(nil,serviceError)
        }
    }
    
    
}






