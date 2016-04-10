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
    var avatarHash : String?
    var type : MemberType = .Normal
    var points = 0
    
    enum MemberType {
        case Admin
        case Normal
    }
    
    init(dictionary: [String : AnyObject]){
        id = dictionary["id"] as? String
        username = dictionary["username"] as? String
        fullname = dictionary["fullName"] as? String
        avatarHash = dictionary["avatarHash"] as? String
    }
    
    func fetchPicture(completionHandler: (UIImage?,NSError?) -> Void){
        if let picture = picture {
            completionHandler(picture,nil)
        }
        else {
            if let avatarHash = avatarHash,
                let avatarImageUrl = NSURL(string: "https://trello-avatars.s3.amazonaws.com/\(avatarHash)/50.png"), let imageData = NSData(contentsOfURL: avatarImageUrl){
                picture = UIImage(data: imageData)
                completionHandler(picture,nil)
            }
            else {
                let imageLoadError = NSError(domain: "Image Load", code: 1, userInfo: nil)
                completionHandler(nil,imageLoadError)
            }
        }
    }
}
