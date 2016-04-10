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
    var fullname : String?
    var picture : UIImage?
    var points = 0
    
    init(dictionary: [String : AnyObject]){
        id = dictionary["id"] as? String
        username = dictionary["username"] as? String
        fullname = dictionary["fullName"] as? String
    }
    
    func fetchPicture(completionHandler: (UIImage?,NSError?) -> Void){
        // TODO: pega a foto
        completionHandler(nil,nil)
    }
}
