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
    
    var expandedIndexPath = NSIndexPath(forRow: -1, inSection: 0) {
        didSet {
            self.expandCell()
        }
    }
    var boards = [TBOBoard]()
    var count = 0
    var changeFocus = false
    var organization:TBOOrganization!
    var interactionController = TBOInteractionController()
    var interactionCheckTimer: NSTimer?
    var isFirstAction = true
    var colorMembers = ["A10054", "11A695", "005EA1", "A71D1D", "50A14B", "5E3AA4", "C06233", "D7C61F"]
    
    enum InteractionState {
        case Active
        case WaitingForInteraction
        case Inactive
    }
    
    private let expandedCellTime:UInt32 = 3
    private let interactionCheckTime:NSTimeInterval = 5
    private let nonFocusedCellColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
    //  private let innerCellViewColor = UIColor(red:163.0/255.0, green:63.0/255.0, blue:107.0/255.0, alpha:1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        companyName.text = organization.name
        
        //        tableViewConfiguration()
        createGestureRecognizers()
        loadDataWithCompletionBlock {
            self.tableView.reloadData()
            self.resetTimer()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "gotoMembers") {
            let membersView = (segue.destinationViewController) as! MembersViewController
            membersView.board = boards[expandedIndexPath.row]
        }
    }
    
    // MARK: Private helpers
    private func loadDataWithCompletionBlock(block:()->()) {
        TrelloManager.sharedInstance.getBoards(organization!.id!) { (boards, error) in
            guard let boards = boards where error == nil else {
                return
            }
            for board in boards {
                TrelloManager.sharedInstance.getBoard(board.id!, completionHandler: { (board, error) in
                    self.boards += [board!]
                    
                    TrelloManager.sharedInstance.getCardsFromBoard(board!.id!) { (cards, error) in
                        self.count += 1
                        board?.cards = cards
                        board?.matchPointsWithMembers(cards!)
                        if(self.count == boards.count) {
                            let orderedArray = self.boards.sort {
                                ($0).totalPoints > ($1).totalPoints
                            }
                            board?.members?.sortInPlace { $0.points > $1.points }
                            
                            self.boards.removeAll()
                            self.boards = orderedArray
                            
                            block()
                        }
                    }
                    
                })
            }
        }
    }
    
    private func createGestureRecognizers() {
        let swipeUp:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipedUp))
        swipeUp.direction = .Up
        view.addGestureRecognizer(swipeUp)
        
        let swipeDown:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipedDown))
        swipeDown.direction = .Down
        view.addGestureRecognizer(swipeDown)
    }
    
    private func expandCell() {
        retractAlllCells()
        tableView.beginUpdates()
        let board = boards[expandedIndexPath.row]
        let cell = tableView.cellForRowAtIndexPath(expandedIndexPath) as! TBOCell
        cell.expandCellWithMembers(board.members!, andPoints: board.totalPoints)
        tableView.endUpdates()
    }
    
    private func retractAlllCells() {
        for row in 0...tableView.numberOfRowsInSection(0) {
            let cellIndexPath = NSIndexPath(forRow: row, inSection: 0)
            if let cell = tableView.cellForRowAtIndexPath(cellIndexPath) as? TBOCell {
                cell.retract()
            }
        }
    }
    
    @objc private func updateExpandIndexPathToNextCell() {
        let row = (expandedIndexPath.row == boards.count-1) ? 0 : expandedIndexPath.row + 1
        let section = expandedIndexPath.section
        expandedIndexPath = NSIndexPath(forRow: row, inSection: section)
    }
    
    private func resetTimer() {
        interactionCheckTimer?.invalidate()
        interactionCheckTimer = NSTimer.scheduledTimerWithTimeInterval(interactionCheckTime, target: self, selector: #selector(updateExpandIndexPathToNextCell), userInfo: nil, repeats: true)
    }
    
    func swipedUp(sender: UISwipeGestureRecognizer){
        print("swiped up")
        let row = (expandedIndexPath.row == 0) ? boards.count-1 : expandedIndexPath.row - 1
        let section = expandedIndexPath.section
        expandedIndexPath = NSIndexPath(forRow: row, inSection: section)
        resetTimer()
    }
    
    func swipedDown(sender:UISwipeGestureRecognizer){
        print("swiped down")
        let row = (expandedIndexPath.row == boards.count-1) ? 0 : expandedIndexPath.row + 1
        let section = expandedIndexPath.section
        expandedIndexPath = NSIndexPath(forRow: row, inSection: section)
        resetTimer()
    }
    
}

extension CompanyRankingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return boards.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! TBOCell
        cell.indentifier.text = "#"+String(indexPath.row+1)
        
        let board = boards[indexPath.row]
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
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.compare(expandedIndexPath) == NSComparisonResult.OrderedSame){
            if let members = boards[indexPath.row].members {
                return 100 + CGFloat(members.count * 90);
            }
        }
        return 89
    }
    
}