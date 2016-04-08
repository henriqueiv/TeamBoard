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
    var boards = [TBOBoard]()
    
    convenience init(dictionary: [String : AnyObject]){
        self.init()
        id = dictionary["id"] as? String
        name = dictionary["displayName"] as? String
        desc = dictionary["desc"] as? String
        if let jsonMembers = dictionary["members"] as? [[String : AnyObject]]{
            for jsonMember in jsonMembers {
                let member = TBOMember(dictionary: jsonMember)
                members.append(member)
            }
        }
    }
    
    func fetchBoards(completionHandler:([TBOBoard]?,NSError?) -> Void){
        TrelloManager.sharedInstance.getBoards(id!, completionHandler: completionHandler)
    }
    
    func fetchBoardsInBackground(){
        TrelloManager.sharedInstance.getBoards(id!) { (boards, error) in
            if let _ = error {
                print(">> FetchBoards Error >>\n\(error.debugDescription)")
            }
            else {
                if let boards = boards {
                    self.boards = boards
                }
            }
        }
    }
}
