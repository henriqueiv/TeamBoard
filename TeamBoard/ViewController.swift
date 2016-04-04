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
    
    let key = "43611b805c9d34e882d8c802e3734678"
    let secret = "aeb284fb3e27508b77b2006af08e673d08696ae2324bb87718ed1d8baaa4791a"
    let token = "951818ea31c3ae149cc0fb067c9a96bf9d4dda8e68c8cf0171737b035faacdb3"
    let AppName = "Satan%20App"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        //authorizeWithOAuth()
        
        // Do any additional setup after loading the view, typically from a nib.
        
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
        let baseURL = "https://trello.com/1"
        let requestTokenAction = "OAuthGetRequestToken"
        let authorizeTokenAction = "OAuthAuthorizeToken"
        let getAccessTokenAction = "OAuthGetAccessToken"
        
        let urlString = "\(baseURL)/connect?key=\(key)&name=\(AppName)&response_type=token&expires=never"
        print(urlString)
        
        //        let urlString = baseURL + requestTokenAction
        let parms = [
            "key":key,
            "name":AppName,
            "respose_type":"token",
            "expires":"never"
        ]
        
        let headers = ["":""]
        Alamofire.request(.GET, "\(baseURL)/connect", parameters: parms, encoding: .URLEncodedInURL).response { (request, response, data, error) in
            print(request)
            print(response)
            print(data)
            print(error)
        }
        
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPMethod = "GET"
        
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        session.dataTaskWithRequest(request) { (data:NSData?, response:NSURLResponse?, error:NSError?) in
            print(response)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

