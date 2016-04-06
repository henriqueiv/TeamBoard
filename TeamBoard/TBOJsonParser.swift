//
//  TBOJsonParser.swift
//  TeamBoard
//
//  Created by Fabio Innocente on 4/4/16.
//  Copyright © 2016 MC. All rights reserved.
//

import Alamofire

extension TrelloManager {
    func getMember(completionHandler:MemberCompletionHandler?){
        if let token = token {
            let memberFromTokenUrl = TrelloManager.baseUrl+"token/\(token)/member?"+TrelloManager.appKeyParameterWithValue+"&token=\(token)"
            Alamofire.request(.GET, memberFromTokenUrl, parameters: nil)
                .responseJSON { response in
                    if (response.result.error == nil) {
                        let jsonData = response.result.value as! [String : AnyObject]
                        if jsonData["Success"] != nil {
//                            let jsonOrganizations = jsonData["organizations"] as! [[String: AnyObject]]
//                            for jsonOrganization in jsonOrganizations {
//                                let organization = TBOOrganization(dictionary: jsonOrganization)
//                                organizations.append(organization)
//                            }
//                            completionHandler?(organizations,nil)
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
    
    func getOrganizations(memberID:String,completionHandler: OrganizationCompletionHandler?){
        if let token = token {
            let organizationUrl = TrelloManager.baseUrl+"members/\(memberID)/organizations?"+TrelloManager.appKeyParameterWithValue+"&token=\(token)"
            Alamofire.request(.GET, organizationUrl, parameters: nil)
                .responseJSON { response in
                    if (response.result.error == nil) {
                        let jsonData = response.result.value as! [String : AnyObject]
                        if jsonData["Success"] != nil {
                            var organizations = [TBOOrganization]()
                            let jsonOrganizations = jsonData["organizations"] as! [[String: AnyObject]]
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
            let serviceError = NSError(domain: "Service Token", code: 1, userInfo: nil)
            completionHandler?(nil,serviceError)
        }
    }
    func getBoards(organizationID:String,completionHandler: BoardsCompletionHandler?){
        if let token = token {
            let boardsURL = TrelloManager.baseUrl+"organizations/\(organizationID)/boards?"+TrelloManager.appKeyParameterWithValue+"lists=all&cards=all&cards_checklists=all&members=all&token=\(token)"
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
