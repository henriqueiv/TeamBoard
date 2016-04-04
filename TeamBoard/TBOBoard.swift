//
//  TBOBoard.swift
//  TeamBoard
//
//  Created by Fabio Innocente on 4/1/16.
//  Copyright © 2016 MC. All rights reserved.
//

import Foundation

class TBOBoard: NSObject {
    var id : String?            // from GET /1/members/<id>/boards
    var name : String?          // from GET /1/members/<id>/boards
    var members : [TBOMember]?  // from GET /1/members/<id>/boards
    var lists : [TBOList]?      // from GET /1/boards/<id>/lists
    
//    convenience init(dictionary: [String : AnyObject]){
//       self.init()
//    }
    
    func loadBoards(){
        let path = NSBundle.mainBundle().pathForResource("member", ofType: "json")
        let jsonData = NSData(contentsOfFile: path!)
        do{
        let jsonResult = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.MutableContainers) as! [NSDictionary]
                    print(jsonResult)
        }catch{}
    }
    
}