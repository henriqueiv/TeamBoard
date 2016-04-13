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
    
    var expandedIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    var arrayBoards = NSMutableArray()
    var count = 0
    var changeFocus = false
    var organization:TBOOrganization!
    
    private let expandedCellTime:UInt32 = 3
    
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
                        if(self.count == boards.count) {
                            let ordenedArray = self.arrayBoards.sort {
                                ($0 as! TBOBoard).totalPoints > ($1 as! TBOBoard).totalPoints
                            }
                            board?.members?.sortInPlace { $0.points > $1.points }
                            
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
    
    private func iterateCellBoards() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            while(true) {
                for var i in 0..<self.arrayBoards.count {
                    sleep(self.expandedCellTime)
                    if(self.changeFocus) {
                        i = self.expandedIndexPath.row + 1
                        self.changeFocus = false
                    }
                    
                    let cellPath = NSIndexPath(forRow: i, inSection: 0)
                    dispatch_async(dispatch_get_main_queue()) {
                        if(i > 0) {
                            let oldCellPath = NSIndexPath(forRow: i-1, inSection: 0)
                            let cell = self.tableView.cellForRowAtIndexPath(oldCellPath) as! TBOCell
                            self.normalCellBoard(cell)
                        } else {
                            let oldCellPath = NSIndexPath(forRow: self.arrayBoards.count-1, inSection: 0)
                            let cell = self.tableView.cellForRowAtIndexPath(oldCellPath) as! TBOCell
                            self.normalCellBoard(cell)
                        }
                        self.expandedIndexPath = cellPath
                        let cell = self.tableView.cellForRowAtIndexPath(cellPath) as! TBOCell
                        self.expandCellBoard(cell)
                    }
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        print(arrayBoards.count)
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
            imageView.showActivityIndicator = true
            imageView.activityIndicatorStyle = .White
            imageView.contentMode = .ScaleAspectFill
            imageView.layer.cornerRadius = CGRectGetWidth(imageView.frame)/4
            imageView.clipsToBounds = true
            imageView.tag = 11 * i
            if(member.pictureURL == nil) {
                imageView.image = UIImage(named: "userwithoutphoto")
                imageView.contentMode = .ScaleAspectFit
            } else {
                imageView.imageURL = member.pictureURL
            }
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
            cell.teamName.hidden = false
        }
        cell.focusStyle = .Custom
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("gotoMembers", sender: nil)
        print(self.expandedIndexPath.row)
    }
    
    func expandCellBoard(cell: TBOCell){
        tableView.beginUpdates()
        cell.teamName.hidden = false
        cell.view.hidden = false
        let board = arrayBoards.objectAtIndex(expandedIndexPath.row) as! TBOBoard
        
        for i in 0..<board.members!.count {
            let member = board.members![i]
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
            cell.layer.cornerRadius = cell.frame.size.width/100
            cell.backgroundColor = UIColor.whiteColor()
            cell.view.addSubview(imageView)
            
            let sizeViewPoints = CGFloat(((member.points)*100)/((board.totalPoints)+1))
            print(String(sizeViewPoints/100))
            let view = UIView(frame:CGRectMake(150, (y+30), (400*(sizeViewPoints/100)), 20))
            view.backgroundColor = UIColor(red:163.0/255.0, green:63.0/255.0, blue:107.0/255.0, alpha:1.0)
            view.layer.cornerRadius = view.layer.frame.height/2
            view.layer.masksToBounds = true
            cell.view.addSubview(view)
            
            let label = UILabel(frame:CGRectMake((160+(400*(sizeViewPoints/100))), (y+30), 200, 20))
            label.text = String(member.points)
            label.font = UIFont(name: label.font.fontName, size: 18)
            label.textColor = UIColor(red:163.0/255.0, green:63.0/255.0, blue:107.0/255.0, alpha:1.0)
            cell.view.addSubview(label)
            
        }
        cell.backgroundColor = UIColor.whiteColor()
        tableView.endUpdates()
    }
    
    func normalCellBoard(cell:TBOCell){
        cell.teamName.hidden = false
        cell.view.hidden = true
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.compare(expandedIndexPath) == NSComparisonResult.OrderedSame){
            if let board = arrayBoards[indexPath.row] as? TBOBoard, let members = board.members {
                return 100 + CGFloat(members.count*90);
            }
        }
        
        return 89
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "gotoMembers") {
            let membersView = (segue.destinationViewController) as! MembersViewController
            membersView.board = self.arrayBoards.objectAtIndex(self.expandedIndexPath.row) as! TBOBoard
        }
    }
    
    func swipedUp(sender:UISwipeGestureRecognizer){
        print("swiped up")
        if(self.expandedIndexPath.row > 0){
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
        if(self.expandedIndexPath.row < self.arrayBoards.count-1){
            var cell = self.tableView.cellForRowAtIndexPath(self.expandedIndexPath) as! TBOCell
            self.normalCellBoard(cell)
            self.expandedIndexPath = NSIndexPath(forRow: self.expandedIndexPath.row + 1, inSection: 0)
            cell = self.tableView.cellForRowAtIndexPath(self.expandedIndexPath) as! TBOCell
            self.expandCellBoard(cell)
            changeFocus = true
        }else{
            print("aqui")
        }
    }
}

