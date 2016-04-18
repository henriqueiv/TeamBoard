//
//  CellMember.swift
//  TeamBoard
//
//  Created by Lucas Fraga Schuler on 18/04/16.
//  Copyright © 2016 MC. All rights reserved.
//

import UIKit

class CellMember: UITableViewCell {

    @IBOutlet weak var indentifier: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var trophy: UIImageView!
    @IBOutlet weak var teamName: UILabel!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var userName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func expand(member: TBOMember){
        let cardColor = UIColor(red:232.0/255.0, green:232.0/255.0, blue:232.0/255.0, alpha:1.0)
        self.view.hidden = false
        self.userName.text = "" // FIXME: why?! There is a name on cell header
        let pictureURL = (member.pictureURL == nil) ? NSURL() : member.pictureURL!
        self.avatar.imageURL = pictureURL
        self.avatar.layer.cornerRadius = self.avatar.frame.height/4
        self.avatar.clipsToBounds = true
        for i in 0..<member.cards.count{
            var label : UILabel
            let y = CGFloat(i * 70) + 15 // FIXME: calculate middle of space - half card height
            label = UILabel(frame:CGRectMake(309, y, 500, 60))
            let card = member.cards[i] as! TBOCard
            label.text = card.name!
            label.backgroundColor = cardColor
            label.font = UIFont(name: label.font.fontName, size: 28)
            label.layer.cornerRadius = 8
            label.layer.masksToBounds = true
            label.textAlignment = .Center
            self.view.layer.cornerRadius = self.frame.size.width/100
            self.view.addSubview(label)
        }
        self.backgroundColor = UIColor.whiteColor()
        self.view.hidden = true
    }
    
    func retract(){
        let nonFocusedCellColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
        self.view.hidden = true
        self.backgroundColor = nonFocusedCellColor
    }
    
    func showView(){
        view.hidden = false
    }
    
    func hiddenView(){
        view.hidden = true
    }
}
