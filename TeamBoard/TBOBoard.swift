//
//  TBOBoard.swift
//  TeamBoard
//
//  Created by Fabio Innocente on 4/1/16.
//  Copyright © 2016 MC. All rights reserved.
//

import Foundation

// Token > Member(me) > Organization > Boards > Membership, Members, Lists & Cards

class TBOBoard: NSObject {
    var id : String?            // from GET /1/members/<id>/boards
    var name : String?          // from GET /1/members/<id>/boards
    var members : [TBOMember]?  // from GET /1/members/<id>/boards
    var lists : [TBOList]?      // from GET /1/boards/<id>/lists
    var cards : [TBOCard]?
    var totalPoints = 0
    
    convenience init(dictionary: [String : AnyObject]){
       self.init()
        id = dictionary["id"] as? String
        name = dictionary["name"] as? String
        cards = [TBOCard]()
        members = [TBOMember]()
        if let jsonMembers = dictionary["members"] as? [[String:AnyObject]] {
            for jsonMember in jsonMembers {
                let member = TBOMember(dictionary: jsonMember)
                if let jsonMemberships = dictionary["memberships"] as? [[String: AnyObject]] {
                    for jsonMembership in jsonMemberships {
                        if let jsonMemberIdOnMembership = jsonMembership["idMember"] as? String,
                            let jsonMemberTypeOnMembership = jsonMembership["typeMember"] as? String{
                            if jsonMemberIdOnMembership == member.id! && jsonMemberTypeOnMembership == "admin" {
                                member.type = .Admin
                            }
                        }
                    }
                }
                
                members?.append(member)
            }
        }
    
        lists = [TBOList]()
        if let jsonLists = dictionary["lists"] as? [[String:AnyObject]] {
            for jsonList in jsonLists {
                let list = TBOList(dictionary: jsonList)
                lists!.append(list)
            }
        }
    }
    
    func matchPointsWithMembers(cards:[TBOCard]){
        var idList: String?
        for list in lists!{
            if list.name!.caseInsensitiveCompare("Done") == .OrderedSame {
                idList = list.id
            }
        }
        for card in cards {
            if card.idList == idList {
                if let boardMembers = members {
                    let membersWithoutPoints = boardMembers.filter({ (boardMember) -> Bool in
                        if let cardMembers = card.members {
                            for cardMember in cardMembers {
                                if cardMember.id == boardMember.id{
                                    return true
                                }
                            }
                        }
                        return false
                    })
                    
                    for memberWithoutPoints in membersWithoutPoints {
                        memberWithoutPoints.points += card.points
                        self.totalPoints += card.points
                    }
                }
            }
        }
    }
}