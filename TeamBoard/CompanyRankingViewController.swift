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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //iterateCell()
    }
    
//    func iterateCell(){
//        //let firstIndexPath = NSIndexPath(forRow: 2, inSection: 0)
//      //  self.tableView.selectRowAtIndexPath(firstIndexPath, animated: true, scrollPosition: .Top)
//
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
//            while(true){
//              for(var i=0; i<self.cookies.count; i++){
//                 let cellPath = NSIndexPath(forRow: i, inSection: 0)
//                 let cell = self.tableView.cellForRowAtIndexPath(cellPath)
//                 dispatch_async(dispatch_get_main_queue()) {
////                    self.tableView.selectRowAtIndexPath(cellPath, animated: true, scrollPosition: UITableViewScrollPosition.None);
//                 }
//                sleep(2)
//                }
//            }
//        }
//    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! TBOCell
        cell.indentifier.text = "#"+String(indexPath.row+1)
        for(var i=0; i<cookies.count; i=i+1){
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
        for(var i=0; i<cookies.count; i=i+1){
            var imageView : UIImageView
            let y = CGFloat(i * 65) + 15
            imageView  = UIImageView(frame:CGRectMake(106, y, 60, 60))
            imageView.image = UIImage(named: "user")!
            selectedCell.view.addSubview(imageView)
        }
        tableView.endUpdates()
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        print(indexPath.row)
        let selectedCell:TBOCell = tableView.cellForRowAtIndexPath(indexPath) as! TBOCell
        selectedCell.teamName.hidden=true
        selectedCell.view.hidden=true
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.compare(self.expandedIndexPath) == NSComparisonResult.OrderedSame){
            return 100 + CGFloat(self.cookies.count*65);
        }
        return 89
    }
}



