//
//  CompanyRankingViewController.swift
//  TeamBoard
//
//  Created by Henrique Valcanaia on 4/1/16.
//  Copyright © 2016 MC. All rights reserved.
//

import UIKit

class CompanyRankingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let cookies = ["Chocolate Chip":0.25,"Oatmeal":0.26,"Peanut Butter":0.02,"Sugar":0.03]
    var expandedIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    var arrayBoards:NSMutableArray = NSMutableArray()
    var count = 0
    var changeFocus = false
    
    var organization:TBOOrganization!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.companyName.text = organization.name
        
        let swipeUp:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("swipedUp:"))
        swipeUp.direction = .Up
        view.addGestureRecognizer(swipeUp)
        
        let swipeDown:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("swipedDown:"))
        swipeDown.direction = .Down
        view.addGestureRecognizer(swipeDown)
        
        TrelloManager.sharedInstance.getBoards(organization!.id!) { (boards, error) in
            guard let boards = boards where error == nil else {
                return
            }
            for board in boards {
                TrelloManager.sharedInstance.getBoard(board.id!, completionHandler: { (board, error) in
                    self.arrayBoards.addObject(board!)
                    
                     TrelloManager.sharedInstance.getCardsFromBoard(board!.id!) { (cards, error) in
                        self.count += 1
                        board?.matchPointsWithMembers(cards!)
                        if(self.count == boards.count){
                            let ordenedArray = self.arrayBoards.sort({
                                ($0 as? TBOBoard)!.totalPoints > ($1 as? TBOBoard)!.totalPoints
                            })
                            self.arrayBoards.removeAllObjects()
                            self.arrayBoards.addObjectsFromArray(ordenedArray)
                            self.tableView.reloadData()
                            self.iterateCellBoards()
                        }
                    }
                    
                })
            }
        }
    }
    
    func iterateCellBoards(){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            while(true){
              for var i in 0..<self.arrayBoards.count{
                 sleep(2)
                if(self.changeFocus){
                    i=self.expandedIndexPath.row+1
                    self.changeFocus=false
                }
                 let cellPath = NSIndexPath(forRow: i, inSection: 0)
                 dispatch_async(dispatch_get_main_queue()) {               
                    if(i>0){
                        let oldCellPath = NSIndexPath(forRow: i-1, inSection: 0)
                        let cell = self.tableView.cellForRowAtIndexPath(oldCellPath) as! TBOCell
                        self.normalCellBoard(cell)
                    }else{
                        let oldCellPath = NSIndexPath(forRow: self.arrayBoards.count-1, inSection: 0)
                        let cell = self.tableView.cellForRowAtIndexPath(oldCellPath) as! TBOCell
                        self.normalCellBoard(cell)
                    }
                    self.expandedIndexPath = cellPath
                    let cell = self.tableView.cellForRowAtIndexPath(cellPath) as! TBOCell
                    self.expandCellBoard(cell)
                 }
                //sleep(2)
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(arrayBoards.count)
        return arrayBoards.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! TBOCell
        cell.indentifier.text = "#"+String(indexPath.row+1)
        let board = arrayBoards.objectAtIndex(indexPath.row) as! TBOBoard
        for i in 0..<board.members!.count {
            let member = board.members![i]
            let x = CGFloat(i * 110) + 106
            let imageView  = AsyncImageView(frame:CGRectMake(x, 14, 73, 61))
            imageView.contentMode = UIViewContentMode.ScaleAspectFill
            imageView.layer.cornerRadius = CGRectGetWidth(imageView.frame)/4.0
            imageView.clipsToBounds = true
            imageView.imageURL = member.pictureURL
            print(member.pictureURL)
            cell.layer.cornerRadius = cell.frame.size.width/100
            cell.backgroundColor = UIColor.whiteColor()
            cell.addSubview(imageView)
            cell.layoutIfNeeded()
            cell.setNeedsDisplay()
        }
        cell.teamName.text = board.name
        cell.score.text = String(board.totalPoints)
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
        self.performSegueWithIdentifier("gotoMembers", sender: nil)
        print(self.expandedIndexPath.row)
    }
    
    func expandCellBoard(cell: TBOCell){
        tableView.beginUpdates()
        cell.teamName.hidden=false
        cell.view.hidden=false
        let board = self.arrayBoards.objectAtIndex(self.expandedIndexPath.row) as! TBOBoard
        
        for i in 0..<board.members!.count {
            let member = board.members![i]
            let y = CGFloat(i * 70) + 20
            let imageView  = AsyncImageView(frame:CGRectMake(70, y, 73, 61))
            imageView.contentMode = UIViewContentMode.ScaleAspectFill
            imageView.layer.cornerRadius = CGRectGetWidth(imageView.frame)/4.0
            imageView.clipsToBounds = true
            imageView.imageURL = member.pictureURL
            cell.layer.cornerRadius = cell.frame.size.width/100
            cell.backgroundColor = UIColor.whiteColor()
            cell.view.addSubview(imageView)
        }
        cell.backgroundColor = UIColor.whiteColor()
        tableView.endUpdates()
    }
    
    func normalCellBoard(cell:TBOCell){
        cell.teamName.hidden=true
        cell.view.hidden=true
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.compare(self.expandedIndexPath) == NSComparisonResult.OrderedSame){
            return 100 + CGFloat(self.cookies.count*65);
        }
        return 89
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "gotoMembers")
        {
            let membersView = (segue.destinationViewController) as! MembersViewController
            membersView.board = self.arrayBoards.objectAtIndex(self.expandedIndexPath.row) as! TBOBoard
        }
    }
    
    func swipedUp(sender:UISwipeGestureRecognizer){
        print("swiped up")
        if(self.expandedIndexPath.row>0){
            var cell = self.tableView.cellForRowAtIndexPath(self.expandedIndexPath) as! TBOCell
            self.normalCellBoard(cell)
            self.expandedIndexPath = NSIndexPath(forRow: self.expandedIndexPath.row-1, inSection: 0)
            cell = self.tableView.cellForRowAtIndexPath(self.expandedIndexPath) as! TBOCell
            self.expandCellBoard(cell)
            changeFocus=true

        }
    }
    
    func swipedDown(sender:UISwipeGestureRecognizer){
        print("swiped down")
        if(self.expandedIndexPath.row<self.arrayBoards.count-1){
            var cell = self.tableView.cellForRowAtIndexPath(self.expandedIndexPath) as! TBOCell
            self.normalCellBoard(cell)
            self.expandedIndexPath = NSIndexPath(forRow: self.expandedIndexPath.row+1, inSection: 0)
            cell = self.tableView.cellForRowAtIndexPath(self.expandedIndexPath) as! TBOCell
            self.expandCellBoard(cell)
            changeFocus=true
        }else{
            print("aqui")
        }
    }
}

