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
    @IBOutlet weak var welcomeLabel: UILabel!
    
    private var organizations = [TBOOrganization]()
    
    override func viewDidLoad() {
        let fullName = TrelloManager.sharedInstance.member?.fullname
        let postfix = (fullName == nil ? "!" : " \(fullName)!")
        welcomeLabel.text = "Welcome\(postfix) :]"
        
        setupTableView()
        loadData()
    }
    
    private func loadData() {
        TrelloManager.sharedInstance.getOrganizations { (organizations, error) in
            guard let organizations = organizations where error == nil else {
                return
            }
            for organization in organizations {
                print("Organization : \(organization.name!)")
                self.organizations = organizations
            }
            self.tableView.reloadData()
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
}

// MARK: - UITableViewDataSource
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


// MARK: - UITableViewDelegate
extension OrganizationSelectionViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let sb = UIStoryboard(name: "CompanyRanking", bundle: NSBundle.mainBundle())
        let vc = sb.instantiateInitialViewController() as! CompanyRankingViewController
        vc.organization = organizations[indexPath.row]
        presentViewController(vc, animated: true, completion: nil)
        
        print(indexPath)
    }
    
}