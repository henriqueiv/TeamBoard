//
//  OrganizationSelectionViewController.swift
//  TeamBoard
//
//  Created by Henrique Valcanaia on 4/7/16.
//  Copyright © 2016 MC. All rights reserved.
//

import UIKit

class OrganizationSelectionViewController: UIViewController {
    @IBOutlet weak var tableView: TBOTableView!
    @IBOutlet weak var welcomeLabel: UILabel!
    
    private var organizations = [TBOOrganization]()
    
    override func viewDidLoad() {
        if let member = TrelloManager.sharedInstance.member {
            var postfix = "!"
            if let fullName = member.fullname {
                postfix = " \(fullName)!"
            } 
            welcomeLabel.text = "Welcome\(postfix) :]"
        }
        setupTableView()
        loadData()
    }
    
    @objc private func loadData() {
        tableView.showLoader()
        TrelloManager.sharedInstance.getOrganizations { (organizations, error) in
            self.tableView.hideLoader()
            guard let organizations = organizations where error == nil else {
                self.showUnknownError()
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
    
    func showUnknownError(){
        let errorRequest = UIAlertController(title: "Ops..", message: "Check your connection.", preferredStyle: .Alert)
        let errorRequestReloadAction = UIAlertAction(title: "Reload", style: .Default) { (reloadAction) in
            self.loadData()
        }
        
        errorRequest.addAction(errorRequestReloadAction)
        self.presentViewController(errorRequest, animated: true, completion: nil)
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
        
        cell.indentationLevel = 1
        cell.indentationWidth = 20
        cell.textLabel?.text = organizations[indexPath.row].name
        cell.detailTextLabel?.text = organizations[indexPath.row].desc
        cell.layer.cornerRadius = cell.frame.size.width/120
        
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
        tableView.deselectRowAtIndexPath(indexPath, animated: false)        
        print(indexPath)
    }
    
}