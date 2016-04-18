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
    
    func expandCell(members: [TBOMember], points: Int){
        let innerCellViewColor = UIColor(red:163.0/255.0, green:63.0/255.0, blue:107.0/255.0, alpha:1.0)
        teamName.hidden = false
        view.hidden = false
        for i in 0..<members.count {
            let member = members[i]
            let y = CGFloat(i * 90) + 20
            let imageView  = AsyncImageView(frame:CGRectMake(70, y, 70, 70))
            imageView.layer.cornerRadius = CGRectGetWidth(imageView.frame)/2
            imageView.clipsToBounds = true
            
            if(member.pictureURL == nil) {
                imageView.image = UIImage(named: "userwithoutphoto")
            } else {
                imageView.contentMode = UIViewContentMode.ScaleAspectFill
                imageView.imageURL = member.pictureURL
            }
            self.layer.cornerRadius = self.frame.size.width/100
            self.backgroundColor = UIColor.whiteColor()
            self.view.addSubview(imageView)
            
            let sizeViewPoints = CGFloat(((member.points)*100)/((points)+1))
            print(String(sizeViewPoints/100))
            let view = UIView(frame:CGRectMake(150, (y+30), (400*(sizeViewPoints/100)), 20))
            view.backgroundColor = innerCellViewColor
            view.layer.cornerRadius = view.layer.frame.height/2
            view.layer.masksToBounds = true
            self.view.addSubview(view)
            
            let label = UILabel(frame:CGRectMake((160+(400*(sizeViewPoints/100))), (y+30), 200, 20))
            label.text = String(member.points)
            label.font = UIFont(name: label.font.fontName, size: 18)
            label.textColor = UIColor(red:163.0/255.0, green:63.0/255.0, blue:107.0/255.0, alpha:1.0)
            self.view.addSubview(label)
            self.view.hidden = true
        }
    }
    
    
    func retract(){
        let nonFocusedCellColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        self.teamName.hidden = false
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
