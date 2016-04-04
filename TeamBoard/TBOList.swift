//
//  TBOList.swift
//  TeamBoard
//
//  Created by Fabio Innocente on 4/1/16.
//  Copyright © 2016 MC. All rights reserved.
//

import Foundation

class TBOList: NSObject {
    var id : String?
    var name : String?
    var cards : [TBOCard]?
    
    convenience init(dictionary: [String : AnyObject]){
        self.init()
        id = dictionary["id"] as? String
        name = dictionary["name"] as? String
        if let jsonCards = dictionary["cards"] as? [[String: AnyObject]] {
            for jsonCard in jsonCards {
                let card = TBOCard(dictionary: jsonCard)
                cards?.append(card)
            }
        }
    }
}