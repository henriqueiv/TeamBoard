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

class LoginViewController: UIViewController {
    
    let key = "43611b805c9d34e882d8c802e3734678"
    let secret = "aeb284fb3e27508b77b2006af08e673d08696ae2324bb87718ed1d8baaa4791a"
    let token = "951818ea31c3ae149cc0fb067c9a96bf9d4dda8e68c8cf0171737b035faacdb3"
    let AppName = "Satan%20App"
    let baseURL = "https://trello.com/1"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        TrelloManager.sharedInstance.delegate = self
        TrelloManager.sharedInstance.authenticate()
    }
    
}

extension LoginViewController: TrelloManagerDelegate {
    
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
