//
//  MembersViewController.swift
//  TeamBoard
//
//  Created by Lucas Fraga Schuler on 08/04/16.
//  Copyright © 2016 MC. All rights reserved.
//

import UIKit

class MembersViewController: UIViewController {
    
    //private let cardColor = UIColor(red:232.0/255.0, green:232.0/255.0, blue:232.0/255.0, alpha:1.0)
    private let expandedCellTime:UInt32 = 3
    private let interactionCheckTime:NSTimeInterval = 5
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
    var cardsDoing = [TBOCard]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.teamName.text = board.name
        
        for list in self.board.lists! {
            if list.name?.uppercaseString == "DOING" {
                self.idListDoing = list.id
                break
            }
        }
        
        let orderedBoardMembers = board.members?.sort({ $0.points > $1.points })
        board.members = orderedBoardMembers
        for card in board.cards! {
            if card.idList == self.idListDoing {
                self.cardsDoing += [card]
                for member in self.board.members! {
                    for m in card.members! {
                        if m.id == member.id {
                            member.cards.addObject(card)
                            break
                        }
                    }
                }
            }
        }
        
        interactionCheckTimer = NSTimer.scheduledTimerWithTimeInterval(interactionCheckTime, target: self, selector: #selector(iterateCellMembers), userInfo: nil, repeats: true)
        tableview.reloadData()
        
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
                                let cell = self.tableview.cellForRowAtIndexPath(oldCellPath) as! CellMember
                                cell.retract()
                            }else{
                                let oldCellPath = NSIndexPath(forRow: self.board.members!.count-1, inSection: 0)
                                let cell = self.tableview.cellForRowAtIndexPath(oldCellPath) as! CellMember
                                cell.retract()
                            }
                            self.expandedIndexPath = cellPath
                            if let cell = self.tableview.cellForRowAtIndexPath(cellPath) as? CellMember {
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
    
    func expandCellMember(cell: CellMember){
        setAllNormalCells()
        tableview.beginUpdates()
        
//        cell.userName.text = "" // FIXME: why?! There is a name on cell header
//        let member = board.members![self.expandedIndexPath.row]
//        
//        let pictureURL = (member.pictureURL == nil) ? NSURL() : member.pictureURL!
//        cell.avatar.imageURL = pictureURL
//        print(pictureURL)
//        cell.avatar.layer.cornerRadius = cell.avatar.frame.height/4
//        cell.avatar.clipsToBounds = true
//        
//        for i in 0..<member.cards.count{
//            var label : UILabel
//            let y = CGFloat(i * 70) + 15 // FIXME: calculate middle of space - half card height
//            label = UILabel(frame:CGRectMake(309, y, 300, 60))
//            let card = member.cards[i] as! TBOCard
//            label.text = card.name!
//            label.backgroundColor = cardColor
//            label.font = UIFont(name: label.font.fontName, size: 24)
//            label.layer.cornerRadius = 8
//            label.layer.masksToBounds = true
//            label.textAlignment = .Center
//            cell.view.layer.cornerRadius = cell.frame.size.width/100
//            cell.view.addSubview(label)
//        }
//        cell.backgroundColor = UIColor.whiteColor()

        cell.expand(board.members![self.expandedIndexPath.row])
        tableview.endUpdates()
    }
    
    func setAllNormalCells(){
        for i in 0...tableview.numberOfRowsInSection(0) {
            let cellIndexPath = NSIndexPath(forRow: i, inSection: 0)
            if let cell = tableview.cellForRowAtIndexPath(cellIndexPath) as? CellMember {
                cell.retract()
            }
        }
    }
    
    
    /// FIXME: Under analize removing this func
    func swipedUp(sender:UISwipeGestureRecognizer){
        print("swiped up")
    }
    
    /// FIXME: Under analize removing this func
    func swipedDown(sender:UISwipeGestureRecognizer){
        print("swiped down")
    }
    
    override func shouldUpdateFocusInContext(context: UIFocusUpdateContext) -> Bool {
        interactionController.setActive()
        if !interactionCheckTimer.valid {
            interactionCheckTimer = NSTimer.scheduledTimerWithTimeInterval(interactionCheckTime, target: self, selector: #selector(iterateCellMembers), userInfo: nil, repeats: true)
        }
        return true
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension MembersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return board.members!.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableview.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! CellMember
        cell.configCell(board.members!, index: indexPath.row)
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath == expandedIndexPath {
            let member = board.members![self.expandedIndexPath.row]
            if (member.cards.count == 0) {
                return 200
            } else {
                return 120 + CGFloat(member.cards.count * 70);
            }
        }
        
        return 89
    }
    
    func tableView(tableView: UITableView, shouldUpdateFocusInContext context: UITableViewFocusUpdateContext) -> Bool {
        if isFirstAction {
            setAllNormalCells()
        }
        
        if let focusedIndexPath = context.nextFocusedIndexPath,
            let focusedCell = tableView.cellForRowAtIndexPath(focusedIndexPath) as? CellMember {
            var cellsToReload = [focusedIndexPath]
            if let lastFocusedIndexPath = context.previouslyFocusedIndexPath,
                let lastFocusedCell = tableView.cellForRowAtIndexPath(lastFocusedIndexPath) as? CellMember {
                lastFocusedCell.retract()
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
