//
//  TBOMember.swift
//  Pods
//
//  Created by Fabio Innocente on 4/1/16.
//
//

import UIKit

class TBOMember {
    var id: String?
    var username: String?
    var fullname: String?
    var pictureURL: NSURL?
    var avatarHash: String?
    var points = 0
    var type: MemberType = .Normal
    var cards:NSMutableArray = NSMutableArray()
    
    enum MemberType {
        case Admin
        case Normal
    }
    
    convenience init(dictionary: [String : AnyObject]){
        self.init()
        id = dictionary["id"] as? String
        username = dictionary["username"] as? String
        fullname = dictionary["fullName"] as? String
        avatarHash = dictionary["avatarHash"] as? String
        if avatarHash != nil {
            let stringURL = "https://trello-avatars.s3.amazonaws.com/\(avatarHash!)/50.png"
            if let avatarImageUrl = NSURL(string: stringURL) {
                pictureURL = avatarImageUrl
            } else {
                print("nao foi possivel montar a url")
            }
        }
        
    }
    
}
