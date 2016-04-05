//
//  ViewController.swift
//  TeamBoard
//
//  Created by Henrique Valcanaia on 3/31/16.
//  Copyright © 2016 MC. All rights reserved.
//

import Alamofire
import Kanna
import UIKit

class ViewController: UIViewController {
    
    let key = "43611b805c9d34e882d8c802e3734678"
    let secret = "aeb284fb3e27508b77b2006af08e673d08696ae2324bb87718ed1d8baaa4791a"
    let token = "951818ea31c3ae149cc0fb067c9a96bf9d4dda8e68c8cf0171737b035faacdb3"
    let AppName = "Satan%20App"
    let baseURL = "https://trello.com/1"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TrelloManager.sharedInstance.delegate = self
        TrelloManager.sharedInstance.authenticate()
        
        //        authorizeWithOAuth()
        
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
        
        
        let urlString = "\(baseURL)/connect?key=\(key)&name=\(AppName)&response_type=token&expires=never"
        print(urlString)
        
        let parms = [
            "key":key,
            "name":AppName,
            "response_type":"token",
            "expires":"never"
        ]
        
        let url = "\(baseURL)/connect"
        Alamofire.request(.GET, url, parameters: parms, encoding: .URLEncodedInURL).responseString { (response:Response<String, NSError>) in
            switch response.result {
            case .Success(let html):
                if let extractedData = self.extractDataFromHTML(html) {
                    //                    self.clickLogInWithParms(extractedData)
                    self.clickAllowWithParms(extractedData)
                }
                
                
            case .Failure(let error):
                print(error)
            }
        }
    }
    
    private func clickLogInWithParms(parms:[String:String]) {
        let url = "\(baseURL)/login"
        
        let parameters = [
            "returnUrl" : parms["returnUrl"]!,
            "requestKey" : parms["requestKey"]!,
            "user" : "henrique_indalencio@hotmail.com",
            "password" : "senha123"
        ]
        Alamofire.request(.POST, url, parameters: parameters).responseString { (response:Response<String, NSError>) in
            switch response.result {
            case .Success(let html):
                let isGoogleLogin = false
                let email = "henrique_indalencio@hotmail.com"
                let password = "senha123"
                let requestKey = parms["requestKey"]!
                
                self.loginWithEmail(email, password, isGoogleLogin, requestKey)
                print(html)
                
            case .Failure(let error):
                print(error)
            }
        }
    }
    
    private func clickAllowWithParms(parms:[String:String]) {
        let url = "https://trello.com/1/token/approve"
        var parameters = parms
        parameters["returnUrl"] = nil
        parameters["action"] = nil
        Alamofire.request(.POST, url, parameters: parameters).responseString { (response:Response<String, NSError>) in
            switch response.result {
            case .Success(let html):
                let isGoogleLogin = false
                let email = "henrique_indalencio@hotmail.com"
                let password = "senha123"
                let requestKey = parms["requestKey"]!
                
                self.loginWithEmail(email, password, isGoogleLogin, requestKey)
                print(html)
                
            case .Failure(let error):
                print(error)
            }
        }
    }
    
    private func loginWithEmail(email:String, _ password:String, _ isGoogleAccount:Bool, _ requestKey:String) {
        if isGoogleAccount {
            googleLoginWithEmail(email, andPassword: password)
        } else {
            loginWithEmail(email, andPassword: password, andRequestKey: requestKey)
        }
    }
    
    private func googleLoginWithEmail(email:String, andPassword password:String) {
        
    }
    
    private func loginWithEmail(email:String, andPassword password:String, andRequestKey requestKey:String) {
        // https://trello.com/login?returnUrl=%2F1%2Fconnect%3FrequestKey%3D3beaeb64cae241505b848c4dfc0e93a4
        let baseURL = "https://trello.com/1"
        let url = "\(baseURL)/authentication"
        print(url)
        
        let parms:[String : String] = [
            //            "requestKey":requestKey,
            "factors[user]":"henrique_indalencio@hotmail.com",
            "factors[password]":"senha123",
            "method":"password"
        ]
        let headers = [
            "Accept":"*/*",
            "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"
        ]
        
        Alamofire.request(.POST, url, parameters: parms, encoding: .URL, headers: headers).responseString { (response:Response<String, NSError>) in
            switch response.result {
            case .Success(let html):
                print(html)
                let authorizationUrl = self.baseURL + "/authorization/session"
                let parameters = [
                    "authentication":"",
                    "dsc":"af4f3620993bf8a207fb6b595f70fb8f744bdb1b0329acbb5cbbcb9bdec252c2"
                ]
                //                let headers = ["":""]
                Alamofire.request(.POST, authorizationUrl, parameters: parameters, encoding: .URL).responseString(completionHandler: { (response:Response<String, NSError>) in
                    switch response.result {
                    case .Success(let html):
                        print(html)
                    case .Failure(let error):
                        print(error)
                    }
                })
                
            case .Failure(let error):
                print(error)
            }
        }
    }
    
    private func extractDataFromHTML(html:String) -> [String:String]? {
        guard let doc = Kanna.HTML(html: html, encoding: NSUTF8StringEncoding) else {
            return nil
        }
        guard let form = doc.at_xpath("//*[@id=\"surface\"]/div[2]/div[1]/form"), formAction = form["action"] else {
            assertionFailure("NAO CONSEGUIU PEGAR A ACTION DO FORM")
            return nil
        }
        
        guard let inputBtnAllow = doc.at_xpath("//*[@id=\"surface\"]/div[2]/div[1]/form/a[1]"), hrefReturnURL = inputBtnAllow["href"] else {
            assertionFailure("NAO CONSEGUIU PEGAR O hrefReturnURL")
            return nil
        }
        
        guard let inputRequestKey = doc.at_xpath("//*[@id=\"surface\"]/div[2]/div[1]/form/input[2]"), requestKey = inputRequestKey["value"] else {
            assertionFailure("NAO CONSEGUIU PEGAR O REQUEST KEY")
            return nil
        }
        
        guard let inputSignature = doc.at_xpath("//*[@id=\"surface\"]/div[2]/div[1]/form/input[3]"), signature = inputSignature["value"] else {
            assertionFailure("NAO CONSEGUIU PEGAR O SIGNATURE")
            return nil
        }
        
        let collectedData = [
            "returnUrl":hrefReturnURL,
            "action":formAction,
            "requestKey":requestKey,
            "signature":signature,
            "approve":"Allow"
        ]
        
        return collectedData
    }
    
}

extension ViewController: TrelloManagerDelegate {
    
    func didFailToAuthenticate() {
        print("fail to authenticate")
    }
    
    func didAuthenticate() {
        print("authenticated! \(TrelloManager.sharedInstance.token)")
    }
    
    func didCreateAuthenticationOnServerWithId(id:String) {
        // show qrcode
        print("criou authentication no server: \(id)")
        
        let manager = QRCodeManager.sharedInstance
        do {
            let image = try manager.generateQRCodeFromString(id, withFrameSize: CGSize(width: 200, height: 200))
            print(image)
        } catch let error as QRCodeManagerError {
            switch error {
            case .ErrorCreatingFilter:
                print("erro ao criar o filtro")
            case .ErrorGeneratingStringData:
                print("erro ao gerar data da string")
            case .ErrorGettingOutputImage:
                print("erro ao obter a imagem de saída")
            }
        } catch let error {
            print(error)
        }
    }
    
    func didFailToCreateAuthenticationOnServer() {
        print("erro ao criar objeto de autenticacao no servidor!")
    }
    
}
