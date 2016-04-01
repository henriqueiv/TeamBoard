//
//  ViewController.swift
//  TeamBoard
//
//  Created by Henrique Valcanaia on 3/31/16.
//  Copyright © 2016 MC. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let key = "43611b805c9d34e882d8c802e3734678"
        let secret = "aeb284fb3e27508b77b2006af08e673d08696ae2324bb87718ed1d8baaa4791a"
        let token = "951818ea31c3ae149cc0fb067c9a96bf9d4dda8e68c8cf0171737b035faacdb3"
//        let client = TrelloHTTPClient(appKey: key, authToken: token)
//        client.getBoardsWithSuccess({ (sessionDataTask, any) in
//            print(sessionDataTask)
//        }) { (dataTask, error) in
//            print(error)
//        }
        
        //        https://trello.com/1/authorize
        //        https://trello.com/1/authorize?expiration=never&name=SinglePurposeToken&key=REPLACEWITHYOURKEY
        
//        let session = AFURLSessionManager(sessionConfiguration: NSURLSessionConfiguration.defaultSessionConfiguration())
//        let request = NSURLRequest(URL: NSURL(string: "")!)
//        session.dataTaskWithRequest(request) { (response, obj, error) in
//            
//        }
    }
    
    private func authorizeWithOAuth() {
        //        https://trello.com/1/token/approve
        let baseURL = "https://trello.com/1/"
        let requestTokenAction = "OAuthGetRequestToken"
        let authorizeTokenAction = "OAuthAuthorizeToken"
        let getAccessTokenAction = "OAuthGetAccessToken"
        
        let urlString = baseURL + requestTokenAction
        let parms = ["":""]
        Alamofire.request(.GET, urlString, parameters: parms).responseJSON { (response:Response<AnyObject, NSError>) in
            switch response.result {
            case .Success(let value):
                print(value)
                
            case .Failure(let error):
                print(error)
            }
        }
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

