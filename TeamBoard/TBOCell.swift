//
//  TBOCell.swift
//  TeamBoard
//
//  Created by Lucas Fraga Schuler on 04/04/16.
//  Copyright © 2016 MC. All rights reserved.
//

import UIKit

class TBOCell: UITableViewCell {

    @IBOutlet weak var indentifier: UILabel!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var trophy: UIImageView!
    @IBOutlet weak var teamName: UILabel!
    @IBOutlet weak var view: UIView!
    
    @IBOutlet weak var avatar: AsyncImageView!
    @IBOutlet weak var userName: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
