//
//  TBOBoard.swift
//  TeamBoard
//
//  Created by Fabio Innocente on 4/1/16.
//  Copyright © 2016 MC. All rights reserved.
//

import Foundation



// Token > Member > Organização > Boards > Members 

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
            var members = [TBOMember]()
            for jsonMember in jsonMembers {
                let member = TBOMember(dictionary: jsonMember)
                members.append(member)
            }
            membership = TBOMembership(members: members)
        }
        if let jsonLists = dictionary["lists"] as? [[String: AnyObject]] {
            for jsonList in jsonLists {
                let list = TBOList(dictionary: jsonList)
                lists?.append(list)
            }
        }
    }
    
}