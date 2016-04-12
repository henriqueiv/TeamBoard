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
    
    convenience init(dictionary: [String : AnyObject]){
       self.init()
        id = dictionary["id"] as? String
        name = dictionary["name"] as? String
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
//        fetchMembersInBackground()
//        fetchListsInBackground()
    }
    
    func matchPointsWithMembers(cards:[TBOCard]){
        for card in cards {
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
                    memberWithoutPoints.points = card.points
                }
            }
        }
    }
    
//    func fetchMembersInBackground(){
//        TrelloManager.sharedInstance.getMembersFromBoard(id!) { (members, error) in
//            if let _ = error {
//              print(">> FetchMembers Error >>\n\(error.debugDescription)")
//            }
//            else {
//                if let members = members {
//                    for member in members {
//                        self.membership?.members.append([member.id! : member])
//                    }
//                }
//            }
//        }
//    }
    
    
//    func loadPicturesMembers(){
//        for member in members! {
//            member.fetchPicture({ (picture, error) in
//                //nao faz nada
//            })
//        }
//    }
    
    func fetchListsInBackground(){
        TrelloManager.sharedInstance.getLists(id!) { (lists, error) in
            if let _ = error {
                print(">> FetchLists Error >>\n\(error.debugDescription)")
            }
            else {
                if let lists = lists {
                    self.lists = lists
                }
            }
        }
    }
    
}