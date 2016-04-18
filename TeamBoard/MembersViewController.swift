//
//  MembersViewController.swift
//  TeamBoard
//
//  Created by Lucas Fraga Schuler on 08/04/16.
//  Copyright © 2016 MC. All rights reserved.
//

import UIKit

class MembersViewController: UIViewController {
    
    private let cardColor = UIColor(red:232.0/255.0, green:232.0/255.0, blue:232.0/255.0, alpha:1.0)
    private let expandedCellTime:UInt32 = 3
    private let interactionCheckTime:NSTimeInterval = 5
    private let nonFocusedCellColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
    private let innerCellViewColor = UIColor(red:163.0/255.0, green:63.0/255.0, blue:107.0/255.0, alpha:1.0)
    
    
    @IBOutlet weak var teamName: UILabel!
    @IBOutlet weak var tableview: UITableView!
    var board:TBOBoard!
    var expandedIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    var interactionController = TBOInteractionController()
    var interactionCheckTimer : NSTimer!
    var isFirstAction = true
    var changeFocus = false
    var idListDoing: String?
    var cardsDoing:NSMutableArray = NSMutableArray()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.teamName.text = board.name
        
        for list in self.board.lists!{
            if list.name == "DOING"{
                self.idListDoing = list.id
                break
            }
        }
        
        let ordenedBoardMembers = board.members?.sort({ $0.points > $1.points })
        board.members = ordenedBoardMembers
        for card in board.cards! {
            if card.idList == self.idListDoing{
                self.cardsDoing.addObject(card)
                for member in self.board.members!{
                    for m in card.members!{
                        if m.id == member.id{
                            member.cards.addObject(card)
                            break
                        }
                    }
                }
            }
        }
        interactionCheckTimer = NSTimer.scheduledTimerWithTimeInterval(interactionCheckTime, target: self, selector: #selector(iterateCellMembers), userInfo: nil, repeats: true)
        self.tableview.reloadData()
        let swipeUp:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipedUp))
        swipeUp.direction = .Up
        view.addGestureRecognizer(swipeUp)
        
        let swipeDown:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipedDown))
        swipeDown.direction = .Down
        view.addGestureRecognizer(swipeDown)
        
    }
    
    func iterateCellMembers(){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            self.interactionController.updateState()
            while(self.interactionController.state == .Inactive){
                self.interactionCheckTimer.invalidate()
                for var i in 0..<self.board.members!.count{
                    if self.interactionController.state == .Inactive {
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
                            if let cell = self.tableview.cellForRowAtIndexPath(cellPath) as? TBOCell {
                                self.expandCellMember(cell)
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
    
    func expandCellMember(cell: TBOCell){
        setAllNormalCells()
        tableview.beginUpdates()
        cell.view.hidden = false
        
        cell.userName.text = "" // FIXME: why?! There is a name on cell header
        let member = board.members![self.expandedIndexPath.row]
        
        let pictureURL = (member.pictureURL == nil) ? NSURL() : member.pictureURL!
        cell.avatar.imageURL = pictureURL
        print(pictureURL)
        cell.avatar.layer.cornerRadius = cell.avatar.frame.height/4
        cell.avatar.clipsToBounds = true
        
        for i in 0..<member.cards.count{
            var label : UILabel
            let y = CGFloat(i * 70) + 15 // FIXME: calculate middle of space - half card height
            label = UILabel(frame:CGRectMake(300, y, 600, 60))
            let card = member.cards[i] as! TBOCard
            label.text = card.name!
            label.backgroundColor = cardColor
            label.font = UIFont(name: label.font.fontName, size: 28)
            label.layer.cornerRadius = 8
            label.layer.masksToBounds = true
            label.textAlignment = .Center
            cell.view.layer.cornerRadius = cell.frame.size.width/100
            cell.view.addSubview(label)
        }
        cell.backgroundColor = UIColor.whiteColor()
        tableview.endUpdates()
    }
    
    func normalCellMember(cell:TBOCell){
        cell.view.hidden = true
        cell.backgroundColor = nonFocusedCellColor
    }
    
    func setAllNormalCells(){
        for i in 0...tableview.numberOfRowsInSection(0) {
            let cellIndexPath = NSIndexPath(forRow: i, inSection: 0)
            if let cell = tableview.cellForRowAtIndexPath(cellIndexPath) as? TBOCell {
                normalCellMember(cell)
            }
        }
    }
    
    
    /// FIXME: Under analize removing this func
    func swipedUp(sender:UISwipeGestureRecognizer){
        print("swiped up")
        if(self.expandedIndexPath.row>0){
//            var cell = self.tableview.cellForRowAtIndexPath(self.expandedIndexPath) as! TBOCell
//            self.normalCellMember(cell)
//            self.expandedIndexPath = NSIndexPath(forRow: self.expandedIndexPath.row-1, inSection: 0)
//            cell = self.tableview.cellForRowAtIndexPath(self.expandedIndexPath) as! TBOCell
//            self.expandCellMember(cell)
//            changeFocus=true
        }
    }
    
    /// FIXME: Under analize removing this func
    func swipedDown(sender:UISwipeGestureRecognizer){
        print("swiped down")
        if(self.expandedIndexPath.row<self.board.members!.count){
//            var cell = self.tableview.cellForRowAtIndexPath(self.expandedIndexPath) as! TBOCell
//            self.normalCellMember(cell)
//            self.expandedIndexPath = NSIndexPath(forRow: self.expandedIndexPath.row+1, inSection: 0)
//            cell = self.tableview.cellForRowAtIndexPath(self.expandedIndexPath) as! TBOCell
//            self.expandCellMember(cell)
//            changeFocus=true
        }
    }
    
    override func shouldUpdateFocusInContext(context: UIFocusUpdateContext) -> Bool {
        interactionController.setActive()
        if !interactionCheckTimer.valid {
            interactionCheckTimer = NSTimer.scheduledTimerWithTimeInterval(interactionCheckTime, target: self, selector: #selector(iterateCellMembers), userInfo: nil, repeats: true)
        }
        return true
    }
}

// ---------------------------------------------
// MARK: - Tableview Delegates Extension
// ---------------------------------------------
extension MembersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return board.members!.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableview.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! TBOCell
        cell.indentifier.text = "#"+String(indexPath.row+1)
        cell.layer.cornerRadius = cell.frame.size.width/100
        cell.backgroundColor = nonFocusedCellColor
        cell.alpha = 0.7
        if(indexPath.row == 0){
            let image : UIImage = UIImage(named: "trophy")!
            cell.trophy.image = image
        }
        
        if  let members = board.members {
            cell.score.text =  String(members[indexPath.row].points)
            cell.teamName.text = members[indexPath.row].fullname == nil ? "" : members[indexPath.row].fullname!
            cell.userName.text = members[indexPath.row].username == nil ? "" : members[indexPath.row].username!
        }
        cell.focusStyle = .Custom
        cell.view.hidden = true
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.compare(self.expandedIndexPath) == NSComparisonResult.OrderedSame){
            let member = board.members![self.expandedIndexPath.row]
            if(member.cards.count == 0){return 200}
            return 120 + CGFloat(member.cards.count * 70);
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
                normalCellMember(lastFocusedCell)
                //                lastFocusedCell.backgroundColor = UIColor.blueColor() // DEBUG UTIL
                cellsToReload.append(lastFocusedIndexPath)
                lastFocusedCell.layoutIfNeeded()
                lastFocusedCell.setNeedsDisplay()
                
            }
            expandedIndexPath = focusedIndexPath
            expandCellMember(focusedCell)
            //            focusedCell.backgroundColor = UIColor.redColor() // DEBUG UTIL
            focusedCell.layoutIfNeeded()
            focusedCell.setNeedsDisplay()
        }
        return true
    }
    
}
