//
//  TBOCard.swift
//  TeamBoard
//
//  Created by Fabio Innocente on 4/1/16.
//  Copyright © 2016 MC. All rights reserved.
//

import Foundation

class TBOCard: NSObject {
    var id : String?
    var name : String?
    var members : [TBOMember]?
    
    // XXX: Dictionary below needs members only(idMember field are not its concern)
    convenience init(dictionary: [String : AnyObject]){
        self.init()
        id = dictionary["id"] as? String
        name = dictionary["name"] as? String
        if let jsonMembers = dictionary["members"] as? [[String: AnyObject]] {
            for jsonMember in jsonMembers {
                let member = TBOMember(dictionary: jsonMember)
                members?.append(member)
            }
        }
    }
}