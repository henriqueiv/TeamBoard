//
//  ViewController.swift
//  TeamBoard
//
//  Created by Henrique Valcanaia on 3/31/16.
//  Copyright © 2016 MC. All rights reserved.
//

import Alamofire
import UIKit

class LoginViewController: UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var loginUrlLabel: UILabel!
    
    private var activityIndicator:UIActivityIndicatorView?
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        TrelloManager.sharedInstance.delegate = self
        TrelloManager.sharedInstance.authenticate()
    }
    
    // MARK: Private helpers
    private func setupView() {
        loginUrlLabel.text = ""
        
        activityIndicator = UIActivityIndicatorView(frame: qrCodeImageView.frame)
        activityIndicator!.startAnimating()
        view.addSubview(activityIndicator!)
    }
    
    private func goToTutorial() {
        let sb = UIStoryboard(name: "Tutorial", bundle: NSBundle.mainBundle())
        if let vc = sb.instantiateInitialViewController() as? TutorialViewController {
            presentViewController(vc, animated: true, completion: nil)
        } else {
            assertionFailure("Little friend, did you set the ViewController class as TutorialViewController? :] ")
        }
    }
    
}

extension UILabel {
    func setTextWithFade(text:String) {
        let duration:Double = 1
        UIView.animateWithDuration(duration/2, animations: {
            self.alpha = 0.0
        }) { (finished) in
            self.text = text
            UIView.animateWithDuration(duration/2) {
                self.alpha = 1.0
            }
        }
    }
}

extension UIImageView {
    func setImageWithFade(image:UIImage) {
        let duration:Double = 1
        UIView.animateWithDuration(duration/2, animations: {
            self.alpha = 0.0
        }) { (finished) in
            self.image = image
            UIView.animateWithDuration(duration/2) {
                self.alpha = 1.0
            }
        }
    }
}

// MARK: - TrelloManagerDelegate
extension LoginViewController: TrelloManagerDelegate {
    
    func didFailToAuthenticateWithError(error:NSError) {
        loginUrlLabel.setTextWithFade("An error occurred while trying to authenticate. :(")
    }
    
    func didAuthenticate() {
        goToTutorial()
    }
    
    func didCreateAuthenticationOnServerWithId(id:String) {
        // show qrcode
        print("criou authentication no server: \(id)")
        
        let manager = QRCodeManager.sharedInstance
        let loginUrl = "http://inf.ufrgs.br/~hivalcanaia/TrelloBoard?id=\(id)"
        do {
            let image = try manager.generateQRCodeFromString(loginUrl, withFrameSize: qrCodeImageView.frame.size)
            activityIndicator?.stopAnimating()
            activityIndicator?.removeFromSuperview()
            qrCodeImageView.setImageWithFade(UIImage(CIImage: image))
            
            loginUrlLabel.setTextWithFade(loginUrl)
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
