//
//  OrganizationSelectionViewController.swift
//  TeamBoard
//
//  Created by Henrique Valcanaia on 4/7/16.
//  Copyright © 2016 MC. All rights reserved.
//

import UIKit

class OrganizationSelectionViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var organizations = [TBOOrganization]()
    
    override func viewDidLoad() {
        /// Fabio's tests
        /// >>>>>> DONT TOUCH THIS <<<<<<
        
        TrelloManager.sharedInstance.getMember { (me, error) in
            guard let _ = me where error == nil else {
                return
            }
            TrelloManager.sharedInstance.getOrganizations({ (organizations, error) in
                guard let organizations = organizations where error == nil else {
                    return
                }
                for organization in organizations {
                    print("Organization : \(organization.name!)")
                }
                TrelloManager.sharedInstance.getBoards(organizations[0].id!, completionHandler: { (boards, error) in
                    guard let boards = boards where error == nil else {
                        return
                    }
                    for board in boards {
                        TrelloManager.sharedInstance.getBoard(board.id!, completionHandler: { (board, error) in
                                print("Board: \(board?.name)\nLists: \(board?.lists?.count)")
                            for list in (board?.lists)! {
                                print("Cards \(list.name):\(list.cards?.count)")
                            }
                        })
                    }
                })
            })
        }
        
        setupTableView()
        loadData()
    }
    
    private func loadData() {
        for i in 1...10 {
            let org = TBOOrganization()
            org.desc = "Organization #\(i)'s description"
            org.name = "Oganization #\(i)"
            
            organizations += [org]
        }
        tableView.reloadData()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
}


extension OrganizationSelectionViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return organizations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("OrganizationCell", forIndexPath: indexPath)
        cell.textLabel?.text = organizations[indexPath.row].name
        cell.detailTextLabel?.text = organizations[indexPath.row].desc
        
        return cell
    }
    
}

extension OrganizationSelectionViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let sb = UIStoryboard(name: "CompanyRanking", bundle: NSBundle.mainBundle())
        let vc = sb.instantiateInitialViewController() as! CompanyRankingViewController
        vc.organization = organizations[indexPath.row]
        presentViewController(vc, animated: true, completion: nil)
        
        print(indexPath)
    }
    
}