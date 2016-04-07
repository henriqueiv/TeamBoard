//
//  TBOBoard.swift
//  TeamBoard
//
//  Created by Fabio Innocente on 4/1/16.
//  Copyright © 2016 MC. All rights reserved.
//

import Foundation

// Token > Member(me) > Organization > Boards > Membership, Members, Lists & Cards

class TBOBoard: NSObject {
    var id : String?            // from GET /1/members/<id>/boards
    var name : String?          // from GET /1/members/<id>/boards
    var membership : TBOMembership?  // from GET /1/members/<id>/boards
    var lists : [TBOList]?      // from GET /1/boards/<id>/lists
    
    convenience init(dictionary: [String : AnyObject]){
       self.init()
        id = dictionary["id"] as? String
        name = dictionary["name"] as? String
        if let jsonMembers = dictionary["memberships"] as? [[String: AnyObject]] {
            membership = TBOMembership(dictionary: jsonMembers)
        }
        lists = [TBOList]()
        if let jsonLists = dictionary["lists"] as? [[String:AnyObject]] {
            for jsonList in jsonLists {
                let list = TBOList(dictionary: jsonList)
                lists!.append(list)
            }
        }
//        fetchMembersInBackground()
//        fetchListsInBackground()
    }
    
    func fetchMembersInBackground(){
        TrelloManager.sharedInstance.getMembersFromBoard(id!) { (members, error) in
            if let _ = error {
              print(">> FetchMembers Error >>\n\(error.debugDescription)")
            }
            else {
                if let members = members {
                    for member in members {
                        self.membership?.members.append([member.id! : member])
                    }
                }
            }
        }
    }
    
    func fetchListsInBackground(){
        TrelloManager.sharedInstance.getLists(id!) { (lists, error) in
            if let _ = error {
                print(">> FetchLists Error >>\n\(error.debugDescription)")
            }
            else {
                if let lists = lists {
                    self.lists = lists
                }
            }
        }
    }
    
}