//
//  Membership.swift
//  TeamBoard
//
//  Created by Fabio Innocente on 4/4/16.
//  Copyright © 2016 MC. All rights reserved.
//


import UIKit

class TBOMembership: NSObject {
    var members = [[String : TBOMember]]()
    var admins = [[String : Bool]]()
    
    init(dictionary: [[String : AnyObject]]){
        super.init()
        for jsonMember in dictionary {
            if let memberId = jsonMember["idMember"] as? String {
                let isAdmin = (jsonMember["memberType"] as? String) == "admin"
                admins.append([memberId: isAdmin])
            }
        }
    }
    override init(){
        super.init()
    }
}