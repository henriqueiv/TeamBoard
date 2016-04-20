//
//  TBOCell.swift
//  TeamBoard
//
//  Created by Lucas Fraga Schuler on 04/04/16.
//  Copyright © 2016 MC. All rights reserved.
//

import UIKit

extension Int {
    
    static func random(range: Range<Int> ) -> Int {
        var offset = 0
        
        // allow negative ranges
        if range.startIndex < 0 {
            offset = abs(range.startIndex)
        }
        
        let mini = UInt32(range.startIndex + offset)
        let maxi = UInt32(range.endIndex   + offset)
        
        return Int(mini + arc4random_uniform(maxi - mini)) - offset
    }
    
}

class TBOCell: UITableViewCell {
    
    @IBOutlet weak var indentifier: UILabel!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var trophy: UIImageView!
    @IBOutlet weak var teamName: UILabel!
    @IBOutlet weak var view: UIView!
    
    @IBOutlet weak var avatar: AsyncImageView!
    @IBOutlet weak var userName: UILabel!
    
    private let colorMembers = ["A10054", "11A695", "005EA1", "A71D1D", "50A14B", "5E3AA4", "C06233", "D7C61F"]
    private let nonFocusedCellColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = frame.size.width/100
        layer.masksToBounds = true
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configCell(board: TBOBoard, index: Int){
        self.indentifier.text = "#\(index + 1)"
        for (index, member) in board.members!.enumerate() {
            let x = CGFloat(index * 110) + 106
            let imageView  = AsyncImageView(frame:CGRectMake(x, 14, 73, 61))
            imageView.contentMode = .ScaleAspectFill
            imageView.layer.cornerRadius = CGRectGetWidth(imageView.frame)/4
            imageView.clipsToBounds = true
            if(member.pictureURL == nil) {
                imageView.image = UIImage(named: "userwithoutphoto")
                imageView.contentMode = .ScaleAspectFit
            } else {
                imageView.imageURL = member.pictureURL
            }
            self.backgroundColor = nonFocusedCellColor
            self.addSubview(imageView)
            
            self.layoutIfNeeded()
            self.setNeedsDisplay()
        }
        self.teamName.text = board.name
        self.score.text = String(board.totalPoints)
        if(index == 0){
            let image : UIImage = UIImage(named: "trophy")!
            self.trophy.image = image
        }
        if(index > 0){
            self.teamName.hidden = false
        }
        self.focusStyle = .Custom
    }
    
    func expandCellWithMembers(members: [TBOMember], andPoints points: Int){
        teamName.hidden = false
        self.view.subviews.forEach({ $0.removeFromSuperview() })
        for (index, member) in members.enumerate() {
            let randomColorIndex = Int.random(0...colorMembers.count-1)
            let randomColor = UIColor(hexString: colorMembers[randomColorIndex])
            
            let y = CGFloat(index * 90) + 20
            let imageView = AsyncImageView(frame:CGRectMake(70, y, 70, 70))
            imageView.layer.cornerRadius = CGRectGetWidth(imageView.frame)/2
            imageView.clipsToBounds = true
            
            if(member.pictureURL == nil) {
                imageView.image = UIImage(named: "userwithoutphoto")
            } else {
                imageView.contentMode = UIViewContentMode.ScaleAspectFill
                imageView.imageURL = member.pictureURL
            }
            self.backgroundColor = UIColor.whiteColor()
            self.view.addSubview(imageView)
            
            let sizeViewPoints = CGFloat(((member.points)*100)/((points)+1))
            let view = UIView(frame:CGRectMake(150, (y+30), (400*(sizeViewPoints/100)), 20))
            view.backgroundColor = randomColor
            view.layer.cornerRadius = view.layer.frame.height/2
            view.layer.masksToBounds = true
            self.view.addSubview(view)
            
            let label = UILabel(frame:CGRectMake((160+(400*(sizeViewPoints/100))), (y+30), 200, 20))
            label.text = String(member.points)
            label.font = UIFont(name: label.font.fontName, size: 18)
            label.textColor = randomColor
            self.view.addSubview(label)
        }
    }
    
    func retract(){
        self.teamName.hidden = false
        self.backgroundColor = nonFocusedCellColor
    }
    
    func showViewWithCompletionBlock(completionBlock:(Bool)->()) {
        //        print(#function)
        UIView.animateWithDuration(0.3, animations: {
            self.view.alpha = 1.0
            }, completion: completionBlock)
    }
    
    func hideViewWithCompletionBlock(completionBlock:(Bool)->()) {
        //        print(#function)
        UIView.animateWithDuration(0.3, animations: {
            self.view.alpha = 0.0
            }, completion: completionBlock)
    }
}
