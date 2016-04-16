//
//  CompanyRankingViewController.swift
//  TeamBoard
//
//  Created by Henrique Valcanaia on 4/1/16.
//  Copyright © 2016 MC. All rights reserved.
//

import UIKit

class CompanyRankingViewController: UIViewController {
    
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var expandedIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    var arrayBoards = NSMutableArray()
    var count = 0
    var changeFocus = false
    var organization:TBOOrganization!
    var interactionController = TBOInteractionController()
    var interactionCheckTimer : NSTimer!
    var isFirstAction = true
    
    enum InteractionState {
        case Active
        case WaitingForInteraction
        case Inactive
    }
    
    private let expandedCellTime:UInt32 = 3
    private let interactionCheckTime:NSTimeInterval = 5
    private let nonFocusedCellColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
    private let innerCellViewColor = UIColor(red:163.0/255.0, green:63.0/255.0, blue:107.0/255.0, alpha:1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewConfiguration()
        interactionCheckTimer = NSTimer.scheduledTimerWithTimeInterval(interactionCheckTime, target: self, selector: #selector(iterateCellBoards), userInfo: nil, repeats: true)
        self.companyName.text = organization.name
        
        let swipeUp:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipedUp))
        swipeUp.direction = .Up
        view.addGestureRecognizer(swipeUp)
        
        let swipeDown:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipedDown))
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
                        board?.cards = cards
                        board?.matchPointsWithMembers(cards!)
                        if(self.count == boards.count) {
                            let ordenedArray = self.arrayBoards.sort {
                                ($0 as! TBOBoard).totalPoints > ($1 as! TBOBoard).totalPoints
                            }
                            board?.members?.sortInPlace { $0.points > $1.points }
                            
                            self.arrayBoards.removeAllObjects()
                            self.arrayBoards.addObjectsFromArray(ordenedArray)
                            self.tableView.reloadData()
//                            self.iterateCellBoards()                            
                        }
                    }
                    
                })
            }
        }
    }
    
    func tableViewConfiguration(){
        tableView.remembersLastFocusedIndexPath = true
    }
    
    // FIXME: we need to control the active cell outside of the func. Call this func just to control the state and update the active focused cell
    func iterateCellBoards() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            self.interactionController.updateState()
            while(self.interactionController.state == .Inactive) {
                self.interactionCheckTimer.invalidate()
                for var i in 0..<self.arrayBoards.count {
                    if self.interactionController.state == .Inactive {
                        if(self.changeFocus) {
                            i = self.expandedIndexPath.row + 1
                            self.changeFocus = false
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
                            if let cell = self.tableView.cellForRowAtIndexPath(cellPath) as? TBOCell{
                                self.expandCellBoard(cell)
                            }
                        }
                        sleep(self.expandedCellTime)
                    }
                    else {
                        return
                    }
                }
            }
        }
    }
    
    func expandCellBoard(cell: TBOCell){
        setAllNormalCells()
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
            view.backgroundColor = innerCellViewColor
            view.layer.cornerRadius = view.layer.frame.height/2
            view.layer.masksToBounds = true
            cell.view.addSubview(view)
            
            let label = UILabel(frame:CGRectMake((160+(400*(sizeViewPoints/100))), (y+30), 200, 20))
            label.text = String(member.points)
            label.font = UIFont(name: label.font.fontName, size: 18)
            label.textColor = UIColor(red:163.0/255.0, green:63.0/255.0, blue:107.0/255.0, alpha:1.0)
            cell.view.addSubview(label)
            
        }
        tableView.endUpdates()
    }
    
    func normalCellBoard(cell:TBOCell){
        cell.teamName.hidden = false
        cell.view.hidden = true
        cell.backgroundColor = nonFocusedCellColor
    }
    
    func setAllNormalCells(){
        for i in 0...tableView.numberOfRowsInSection(0) {
            let cellIndexPath = NSIndexPath(forRow: i, inSection: 0)
            if let cell = tableView.cellForRowAtIndexPath(cellIndexPath) as? TBOCell {
                normalCellBoard(cell)
            }
        }
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
//            var cell = self.tableView.cellForRowAtIndexPath(self.expandedIndexPath) as! TBOCell
//            self.normalCellBoard(cell)
//            self.expandedIndexPath = NSIndexPath(forRow: self.expandedIndexPath.row-1, inSection: 0)
//            cell = self.tableView.cellForRowAtIndexPath(self.expandedIndexPath) as! TBOCell
//            self.expandCellBoard(cell)
//            changeFocus = true
        }
    }
    
    func swipedDown(sender:UISwipeGestureRecognizer){
        print("swiped down")
        if(self.expandedIndexPath.row < self.arrayBoards.count-1){
//            var cell = self.tableView.cellForRowAtIndexPath(self.expandedIndexPath) as! TBOCell
//            self.normalCellBoard(cell)
//            self.expandedIndexPath = NSIndexPath(forRow: self.expandedIndexPath.row + 1, inSection: 0)
//            cell = self.tableView.cellForRowAtIndexPath(self.expandedIndexPath) as! TBOCell
//            self.expandCellBoard(cell)
//            changeFocus = true
        }else{
            print("aqui")
        }
    }
    
    override func shouldUpdateFocusInContext(context: UIFocusUpdateContext) -> Bool {
        interactionController.setActive()
        if !interactionCheckTimer.valid {
            interactionCheckTimer = NSTimer.scheduledTimerWithTimeInterval(interactionCheckTime, target: self, selector: #selector(iterateCellBoards), userInfo: nil, repeats: true)
        }
        return true
    }
}

extension CompanyRankingViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayBoards.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! TBOCell
        cell.indentifier.text = "#"+String(indexPath.row+1)
        
        let board = arrayBoards.objectAtIndex(indexPath.row) as! TBOBoard
        for i in 0..<board.members!.count {
            let member = board.members![i]
            let x = CGFloat(i * 110) + 106
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
            print(member.pictureURL)
            cell.layer.cornerRadius = cell.frame.size.width/100
            cell.backgroundColor = nonFocusedCellColor
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
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.compare(expandedIndexPath) == NSComparisonResult.OrderedSame){
            if let board = arrayBoards[indexPath.row] as? TBOBoard, let members = board.members {
                return 100 + CGFloat(members.count*90);
            }
        }
        
        return 89
    }
    
    func tableView(tableView: UITableView, shouldUpdateFocusInContext context: UITableViewFocusUpdateContext) -> Bool {
        if isFirstAction {
            setAllNormalCells()
        }
        
        if let focusedIndexPath = context.nextFocusedIndexPath,
            let focusedCell = tableView.cellForRowAtIndexPath(focusedIndexPath) as? TBOCell {
            var cellsToReload = [focusedIndexPath]
            if let lastFocusedIndexPath = context.previouslyFocusedIndexPath,
                let lastFocusedCell = tableView.cellForRowAtIndexPath(lastFocusedIndexPath) as? TBOCell {
                normalCellBoard(lastFocusedCell)
                //                lastFocusedCell.backgroundColor = UIColor.blueColor() // DEBUG UTIL
                cellsToReload.append(lastFocusedIndexPath)
                lastFocusedCell.layoutIfNeeded()
                lastFocusedCell.setNeedsDisplay()
                
            }
            expandedIndexPath = focusedIndexPath
            expandCellBoard(focusedCell)
            //            focusedCell.backgroundColor = UIColor.redColor() // DEBUG UTIL
            focusedCell.layoutIfNeeded()
            focusedCell.setNeedsDisplay()
        }
        return true
    }
}