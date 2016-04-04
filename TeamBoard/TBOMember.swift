//
//  TBOMember.swift
//  Pods
//
//  Created by Fabio Innocente on 4/1/16.
//
//

import UIKit

class TBOMember: NSObject {
    var id : String?
    var username : String?
    var picture : UIImage?
    
    init(dictionary: [String : AnyObject]){
        id = dictionary["id"] as? String
        username = dictionary["username"] as? String
        // TODO: get picture
    }
}
