//
//  TBOJsonParser.swift
//  TeamBoard
//
//  Created by Fabio Innocente on 4/4/16.
//  Copyright © 2016 MC. All rights reserved.
//

import Foundation

class TBOJsonParser: NSObject {
    
    static func getBoards() -> [TBOBoard]? {
        do {
            // FIXME: trocar linha abaixo pelo getter da API
            let filePath = NSBundle.mainBundle().URLForResource("member_boards", withExtension: "json")!
            if let jsonData = NSData(contentsOfURL: filePath) {
                var boards = [TBOBoard]()
                let json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .MutableContainers)
                if let jsonBoards = json as? [[String : AnyObject]]{
                    for jsonBoard in jsonBoards {
                        let board = TBOBoard(dictionary: jsonBoard)
                        boards.append(board)
                    }
                    return boards
                }
            }
        }
            
        catch {
            print(" -------- Falha na leitura do json ------- ")
        }
        
        return nil
    }
    
    static func getMembersFromBoard() -> [TBOMember]? {
        do {
            // FIXME: trocar linha abaixo pelo getter da API
            let filePath = NSBundle.mainBundle().URLForResource("board_members", withExtension: "json")!
            if let jsonData = NSData(contentsOfURL: filePath) {
                var members = [TBOMember]()
                let json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .MutableContainers)
                if let jsonMembers = json as? [[String : AnyObject]]{
                    for jsonMember in jsonMembers {
                        let member = TBOMember(dictionary: jsonMember)
                        members.append(member)
                    }
                    return members
                }
            }
        }
            
        catch {
            print(" -------- Falha na leitura do json ------- ")
        }
        
        return nil
    }
    
    static func getCards() -> [TBOCard]? {
        do {
            // FIXME: trocar linha abaixo pelo getter da API
            let filePath = NSBundle.mainBundle().URLForResource("list_cards", withExtension: "json")!
            if let jsonData = NSData(contentsOfURL: filePath) {
                var cards = [TBOCard]()
                let json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .MutableContainers)
                if let jsonCards = json as? [[String : AnyObject]]{
                    for jsonCard in jsonCards {
                        let card = TBOCard(dictionary: jsonCard)
                        cards.append(card)
                    }
                    return cards
                }
            }
        }
            
        catch {
            print(" -------- Falha na leitura do json ------- ")
        }
        
        return nil
    }
}
