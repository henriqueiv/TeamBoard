//
//  TBOOrganization.swift
//  TeamBoard
//
//  Created by Fabio Innocente on 4/4/16.
//  Copyright © 2016 MC. All rights reserved.
//

import UIKit

class TBOOrganization: NSObject {
    var id : String?
    var name : String?
    var desc : String?
    var members = [TBOMember]()
    
    init(dictionary: [String : AnyObject]){
        id = dictionary["id"] as? String
        name = dictionary["name"] as? String
        desc = dictionary["desc"] as? String
        if let jsonMembers = dictionary["members"] as? [[String : AnyObject]]{
            for jsonMember in jsonMembers {
                let member = TBOMember(dictionary: jsonMember)
                members.append(member)
            }
        }
    }
}
