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
    let members = ["Camilla Schmidt","Camilla Schmidt","Camilla Schmidt"]
    var expandedIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.iterateCellMembers()
    }
    
    func iterateCellMembers(){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            while(true){
                for i in 0..<3{
                    sleep(1)
                    let cellPath = NSIndexPath(forRow: i, inSection: 0)
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        if(i>0){
                            let oldCellPath = NSIndexPath(forRow: i-1, inSection: 0)
                            let cell = self.tableview.cellForRowAtIndexPath(oldCellPath) as! TBOCell
                            self.normalCellMember(cell)
                        }else{
                            let oldCellPath = NSIndexPath(forRow: 2, inSection: 0)
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
        return 3;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableview.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! TBOCell
        cell.indentifier.text = "#"+String(indexPath.row+1)
        cell.score.text = "4321 Pontos"
        if(indexPath.row == 0){
            let image : UIImage = UIImage(named: "trophy")!
            cell.trophy.image = image
        }
        cell.teamName.text = String(self.members[indexPath.row])
        cell.focusStyle = UITableViewCellFocusStyle.Custom
        cell.view.hidden=true
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.compare(self.expandedIndexPath) == NSComparisonResult.OrderedSame){
            return 100 + CGFloat(self.members.count*70);
        }
        return 89
    }
    
    func expandCellMember(cell: TBOCell){
        tableview.beginUpdates()
        cell.teamName.hidden=false
        cell.view.hidden=false
        let image : UIImage = UIImage(named: "user")!
        cell.avatar.image = image
        cell.userName.text = "userName"
        for i in 0..<members.count{
            var label : UILabel
            let y = CGFloat(i * 70) + 15
            label = UILabel(frame:CGRectMake(309, y, 60, 60))
            label.text = "task"
            label.backgroundColor = UIColor.redColor()
            label.layer.cornerRadius = 8
            label.layer.masksToBounds = true
            cell.view.addSubview(label)
        }
        cell.backgroundColor = UIColor.whiteColor()
        tableview.endUpdates()
    }
    
    func normalCellMember(cell:TBOCell){
        cell.teamName.hidden=true
        cell.view.hidden=true
        cell.backgroundColor = UIColor.clearColor()
    }
}
