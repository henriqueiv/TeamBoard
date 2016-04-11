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
        fetchPictureURL()
    }
    
    private func fetchPictureURL(){
        if let avatarImageUrl = NSURL(string: "https://trello-avatars.s3.amazonaws.com/\(avatarHash)/50.png") {
            pictureURL = avatarImageUrl
        } else {
            print("nao foi possivel montar a url")
        }
    }
}
