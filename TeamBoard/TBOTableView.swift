//
//  TBOTableView.swift
//  TeamBoard
//
//  Created by Fabio Innocente on 4/22/16.
//  Copyright © 2016 MC. All rights reserved.
//

import Foundation

class TBOTableView: UITableView {
    private let loaderRect = CGRect(x: 0, y: 0, width: 200, height: 200)

    var loader : UIActivityIndicatorView
    
    convenience init(){
        self.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        loader = UIActivityIndicatorView(frame: loaderRect)
        super.init(coder: aDecoder)
    }
    
    private func configureTablewViewLoader(){
        loader.center = self.center
    }
    
    func showLoader(){
        configureTablewViewLoader()
        self.addSubview(loader)
        loader.startAnimating()
    }
    
    func hideLoader(){
        loader.stopAnimating()
        loader.removeFromSuperview()
    }
}