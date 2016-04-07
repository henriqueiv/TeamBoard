//
//  CompanyRankingViewController.swift
//  TeamBoard
//
//  Created by Henrique Valcanaia on 4/1/16.
//  Copyright © 2016 MC. All rights reserved.
//

import UIKit

class CompanyRankingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet weak var tableView: UITableView!
    
    let cookies = ["Chocolate Chip":0.25,"Oatmeal":0.26,"Peanut Butter":0.02,"Sugar":0.03]
    var expandedIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    
    var organization:TBOOrganization!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        iterateCell()
    }
    
    func iterateCell(){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            while(true){
              for i in 0..<4{
                 let cellPath = NSIndexPath(forRow: i, inSection: 0)
                 dispatch_async(dispatch_get_main_queue()) {
                    
                    if(i>0){
                        let oldCellPath = NSIndexPath(forRow: i-1, inSection: 0)
                        self.tableView(self.tableView, didDeselectRowAtIndexPath: oldCellPath)
                    }else{
                        let oldCellPath = NSIndexPath(forRow: 3, inSection: 0)
                        self.tableView(self.tableView, didDeselectRowAtIndexPath: oldCellPath)
                    }
                    self.tableView(self.tableView, didSelectRowAtIndexPath: cellPath)
                 }
                sleep(2)
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! TBOCell
        cell.indentifier.text = "#"+String(indexPath.row+1)
        for i in 0..<cookies.count{
            var imageView : UIImageView
            let x = CGFloat(i * 110) + 106
            imageView  = UIImageView(frame:CGRectMake(x, 14, 73, 61))
            imageView.image = UIImage(named: "user")!
            cell.addSubview(imageView)
        }
        cell.score.text = "4321 Pontos"
        if(indexPath.row == 0){
            let image : UIImage = UIImage(named: "trophy")!
            cell.trophy.image = image
        }
        
        if(indexPath.row > 0){
            cell.teamName.hidden = true
        }
        cell.focusStyle = UITableViewCellFocusStyle.Custom
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.beginUpdates()
        if(indexPath.compare(self.expandedIndexPath) == NSComparisonResult.OrderedSame){
            //self.expandedIndexPath = nil
        }else{
            self.expandedIndexPath = indexPath
        }
        let selectedCell:TBOCell = tableView.cellForRowAtIndexPath(indexPath) as! TBOCell
        selectedCell.teamName.hidden=false
        selectedCell.view.hidden=false
        for i in 0..<cookies.count{
            var imageView : UIImageView
            let y = CGFloat(i * 65) + 15
            imageView  = UIImageView(frame:CGRectMake(106, y, 60, 60))
            imageView.image = UIImage(named: "user")!
            selectedCell.view.addSubview(imageView)
        }
        selectedCell.backgroundColor = UIColor.whiteColor()
        tableView.endUpdates()
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        print(indexPath.row)
        let selectedCell:TBOCell = tableView.cellForRowAtIndexPath(indexPath) as! TBOCell
        selectedCell.teamName.hidden=true
        selectedCell.view.hidden=true
        selectedCell.backgroundColor = UIColor.clearColor()
    }

    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.compare(self.expandedIndexPath) == NSComparisonResult.OrderedSame){
            return 100 + CGFloat(self.cookies.count*65);
        }
        return 89
    }
}



