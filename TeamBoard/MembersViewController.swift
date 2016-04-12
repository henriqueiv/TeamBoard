//
//  MembersViewController.swift
//  TeamBoard
//
//  Created by Lucas Fraga Schuler on 08/04/16.
//  Copyright © 2016 MC. All rights reserved.
//

import UIKit

class MembersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableview: UITableView!
    var board:TBOBoard!
    var expandedIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    var changeFocus = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.iterateCellMembers()
        
        let swipeUp:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("swipedUp:"))
        swipeUp.direction = .Up
        view.addGestureRecognizer(swipeUp)
        
        let swipeDown:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("swipedDown:"))
        swipeDown.direction = .Down
        view.addGestureRecognizer(swipeDown)

    }
    
    func iterateCellMembers(){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            while(true){
                for var i in 0..<self.board.members!.count{
                    sleep(2)
                    if(self.changeFocus){
                        i=self.expandedIndexPath.row+1
                        self.changeFocus=false
                    }
                    let cellPath = NSIndexPath(forRow: i, inSection: 0)
                    dispatch_async(dispatch_get_main_queue()) {
                        if(i>0){
                            let oldCellPath = NSIndexPath(forRow: i-1, inSection: 0)
                            let cell = self.tableview.cellForRowAtIndexPath(oldCellPath) as! TBOCell
                            self.normalCellMember(cell)
                        }else{
                            let oldCellPath = NSIndexPath(forRow: self.board.members!.count-1, inSection: 0)
                            let cell = self.tableview.cellForRowAtIndexPath(oldCellPath) as! TBOCell
                            self.normalCellMember(cell)
                        }
                        self.expandedIndexPath = cellPath
                        let cell = self.tableview.cellForRowAtIndexPath(cellPath) as! TBOCell
                        self.expandCellMember(cell)
                    }
                }
            }
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return board.members!.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableview.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! TBOCell
        cell.indentifier.text = "#"+String(indexPath.row+1)
        cell.score.text = "4321 Pontos"
        cell.layer.cornerRadius = cell.frame.size.width/100
        cell.backgroundColor = UIColor.whiteColor()
        if(indexPath.row == 0){
            let image : UIImage = UIImage(named: "trophy")!
            cell.trophy.image = image
        }
        let members = board.members
        cell.teamName.text = String(members![indexPath.row].fullname!)
        cell.userName.text = String(members![indexPath.row].username!)
        cell.userName.text = "sssssssssssssss"
        cell.focusStyle = UITableViewCellFocusStyle.Custom
        cell.view.hidden=true
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.compare(self.expandedIndexPath) == NSComparisonResult.OrderedSame){
            let members = board.members
            return 100 + CGFloat(members!.count*70);
        }
        return 89
    }
    
    func expandCellMember(cell: TBOCell){
        tableview.beginUpdates()
        cell.view.hidden=false
        let image : UIImage = UIImage(named: "user")!
        cell.avatar.image = image
        cell.userName.text = "userName"
        let members = board.members
        for i in 0..<members!.count{
            var label : UILabel
            let y = CGFloat(i * 70) + 15
            label = UILabel(frame:CGRectMake(309, y, 60, 60))
            label.text = "task"
            label.backgroundColor = UIColor.redColor()
            label.layer.cornerRadius = 8
            label.layer.masksToBounds = true
            cell.view.layer.cornerRadius = cell.frame.size.width/100
            cell.view.addSubview(label)
        }
        cell.backgroundColor = UIColor.whiteColor()
        tableview.endUpdates()
    }
    
    func normalCellMember(cell:TBOCell){
        cell.view.hidden=true
    }
    
    func swipedUp(sender:UISwipeGestureRecognizer){
        print("swiped up")
        if(self.expandedIndexPath.row>0){
            var cell = self.tableview.cellForRowAtIndexPath(self.expandedIndexPath) as! TBOCell
            self.normalCellMember(cell)
            self.expandedIndexPath = NSIndexPath(forRow: self.expandedIndexPath.row-1, inSection: 0)
            cell = self.tableview.cellForRowAtIndexPath(self.expandedIndexPath) as! TBOCell
            self.expandCellMember(cell)
            changeFocus=true
        }
    }
    
    func swipedDown(sender:UISwipeGestureRecognizer){
        print("swiped down")
        if(self.expandedIndexPath.row<self.board.members!.count){
            var cell = self.tableview.cellForRowAtIndexPath(self.expandedIndexPath) as! TBOCell
            self.normalCellMember(cell)
            self.expandedIndexPath = NSIndexPath(forRow: self.expandedIndexPath.row+1, inSection: 0)
            cell = self.tableview.cellForRowAtIndexPath(self.expandedIndexPath) as! TBOCell
            self.expandCellMember(cell)
            changeFocus=true
        }
    }
}
