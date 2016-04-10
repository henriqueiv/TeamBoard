//
//  TBOCard.swift
//  TeamBoard
//
//  Created by Fabio Innocente on 4/1/16.
//  Copyright © 2016 MC. All rights reserved.
//

import Foundation

class TBOCard {
    var id: String?
    var name: String?
    var members: [TBOMember]?
    var desc: String?
    var points = 0
    
    // XXX: Dictionary below needs members only(idMember field are not its concern)
    convenience init(dictionary: [String:AnyObject]){
        self.init()
        id = dictionary["id"] as? String
        name = dictionary["name"] as? String
        desc = dictionary["desc"] as? String
        if let jsonMembers = dictionary["members"] as? [[String:AnyObject]] {
            for jsonMember in jsonMembers {
                let member = TBOMember(dictionary: jsonMember)
                members?.append(member)
            }
        }
        
        do{
            try setCardValue()
            members?.forEach { (member) in
                member.points = self.points
            }
        } catch let error {
            print(error)
        }
    }
    
    private func setCardValue() throws {
        if desc != nil {
            let pattern = "#value\\{(\\d+)\\}"
            let matches = try matchesForRegexInText(pattern, text: desc!)
            if let points = NSNumberFormatter().numberFromString(matches[1])?.integerValue {
                self.points = points
            }
            
            print(matches)
        }
    }
    
}