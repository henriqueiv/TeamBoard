//
//  TBOJsonParser.swift
//  TeamBoard
//
//  Created by Fabio Innocente on 4/4/16.
//  Copyright © 2016 MC. All rights reserved.
//

import Alamofire

class TBOJsonParser: NSObject {
    static let baseUrl = "https://api.trello.com/1/"
    static let appKeyParameterWithValue = "key=43611b805c9d34e882d8c802e3734678"
    
    typealias boardsCompletionHandler = ([TBOBoard]?,NSError?)->Void
    typealias membersCompletionHandler = ([TBOMember]?,NSError?)->Void
    typealias listsCompletionHandler = ([TBOList]?,NSError?)->Void
    
    static func getBoards(organizationID:String,completionHandler: boardsCompletionHandler?){
        let boardsURL = baseUrl+"organizations/\(organizationID)/boards?"+appKeyParameterWithValue
        Alamofire.request(.GET, boardsURL, parameters: nil)
            .responseJSON { response in
                if (response.result.error == nil) {
                    let jsonData = response.result.value as! [String : AnyObject]
                    if jsonData["Success"] != nil {
                        var boards = [TBOBoard]()
                        let jsonBoards = jsonData["boards"] as! [[String: AnyObject]]
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

    static func getMembersFromBoard(boardID:String,completionHandler: membersCompletionHandler?) {
        let membersFromBoardURL = baseUrl+"boards/\(boardID)/members?"+appKeyParameterWithValue
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

    static func getLists(boardID:String,completionHandler:listsCompletionHandler?) {
        let membersFromBoardURL = baseUrl+"boards/\(boardID)/lists?"+appKeyParameterWithValue
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
