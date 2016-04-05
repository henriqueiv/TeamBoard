//
//  TBAuthentication.swift
//  TeamBoard
//
//  Created by Henrique Valcanaia on 4/5/16.
//  Copyright © 2016 MC. All rights reserved.
//

import Parse

class TBAuthentication: PFObject, PFSubclassing {

    @NSManaged var token:String
    
    static func parseClassName() -> String {
        return "Authentication"
    }
    
}
