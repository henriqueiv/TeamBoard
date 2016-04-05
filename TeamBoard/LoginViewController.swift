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
    
    //    let key = "43611b805c9d34e882d8c802e3734678"
    //    let secret = "aeb284fb3e27508b77b2006af08e673d08696ae2324bb87718ed1d8baaa4791a"
    //    let token = "951818ea31c3ae149cc0fb067c9a96bf9d4dda8e68c8cf0171737b035faacdb3"
    //    let AppName = "Satan%20App"
    //    let baseURL = "https://trello.com/1"
    
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var loginUrlLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TrelloManager.sharedInstance.delegate = self
        TrelloManager.sharedInstance.authenticate()
    }
    
}

// MARK: - TrelloManagerDelegate
extension LoginViewController: TrelloManagerDelegate {
    
    func didFailToAuthenticateWithError(error:NSError) {
        print("fail to authenticate: \(error)")
    }
    
    func didAuthenticate() {
        print("authenticated! \(TrelloManager.sharedInstance.token)")
        loginUrlLabel.text = "Authenticated! \(TrelloManager.sharedInstance.token)"
        qrCodeImageView.image = nil
    }
    
    func didCreateAuthenticationOnServerWithId(id:String) {
        // show qrcode
        print("criou authentication no server: \(id)")
        
        let manager = QRCodeManager.sharedInstance
        do {
            let loginUrl = "http://inf.ufrgs.br/~hivalcanaia/TrelloBoard?id=\(id)"
            let image = try manager.generateQRCodeFromString(loginUrl, withFrameSize: CGSize(width: 200, height: 200))
            qrCodeImageView.image = UIImage(CIImage: image)
            loginUrlLabel.text = loginUrl
            
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
