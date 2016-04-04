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
    }
    
    func fetchMembersInBackground(){
        // TODO: fetch members in membership of board via TRELLO API -- GET /1/boards/[board_id]/members
    }
    
    func fetchListsInBackground(){
        // TODO: fetch lists(with CARDS) of board via TRELLO API -- GET /1/boards/[board_id]/lists
    }
    
}