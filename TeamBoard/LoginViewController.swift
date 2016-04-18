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
        loginUrlLabel.setTextWithFade("Generating login URL...")
        
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

// MARK: - TrelloManagerDelegate
extension LoginViewController: TrelloManagerDelegate {
    
    func didFailToAuthenticateWithError(error: NSError) {
        loginUrlLabel.setTextWithFade("An error occurred while trying to authenticate, trying again...")
        TrelloManager.sharedInstance.authenticate()
    }
    
    //TODO: Simplify the if maybe?
    func didAuthenticate() {
        TrelloManager.sharedInstance.getMember { (me, error) in
            if error == nil {
                if me != nil {
                    self.goToTutorial()
                } else {
                    self.loginUrlLabel.setTextWithFade("An error occurred while trying to authenticate, trying again...")
                    TrelloManager.sharedInstance.authenticate()
                }
            } else {
                self.loginUrlLabel.setTextWithFade("An error occurred while trying to authenticate, trying again...")
                TrelloManager.sharedInstance.authenticate()
            }
        }
        
    }
    
    func didCreateAuthenticationOnServerWithId(id: String) {
        do {
            let manager = QRCodeManager.sharedInstance
            let loginUrl = "http://inf.ufrgs.br/~hivalcanaia/TrelloBoard?id=\(id)"
            let image = try manager.generateQRCodeFromString(loginUrl, withFrameSize: qrCodeImageView.frame.size)
            activityIndicator?.stopAnimating()
            activityIndicator?.removeFromSuperview()
            qrCodeImageView.setImageWithFade(UIImage(CIImage: image))
            
            let loginUrlAttributedString = NSAttributedString(string: loginUrl, attributes: [NSFontAttributeName : UIFont.boldSystemFontOfSize(loginUrlLabel.font.pointSize)])
            let mutableAttrString = NSMutableAttributedString(string: "Scan the QRCode or go to ")
            mutableAttrString.appendAttributedString(loginUrlAttributedString)
            mutableAttrString.appendAttributedString(NSAttributedString(string: " to log in"))
            loginUrlLabel.setAttributedTextWithFade(mutableAttrString)
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
            TrelloManager.sharedInstance.authenticate()
            print(error)
        }
    }
    
    func didFailToCreateAuthenticationOnServer() {
        loginUrlLabel.setTextWithFade("An error occurred while trying to authenticate, trying again...")
        TrelloManager.sharedInstance.authenticate()
    }
    
}
