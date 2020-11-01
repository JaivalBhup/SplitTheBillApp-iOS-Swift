//
//  UserBillTableViewController.swift
//  SplitTheBill
//
//  Created by Jaival Bhuptani on 2020-10-30.
//

import UIKit
import RealmSwift

class UserBillTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var contributor : Contributor?
    @IBOutlet weak var NameLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: .zero)
        NameLabel.text = contributor?.name
    }

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return contributor?.bill.count ?? 0
    }
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = self.tableView.dequeueReusableCell(withIdentifier: "UserBill", for: indexPath)
        
        cell.textLabel?.text = contributor?.bill[indexPath.row].title
        cell.detailTextLabel?.text = "\(contributor?.bill[indexPath.row].amount ?? 0) INR"
        
        return cell
    }
    
    //MARK:- table view delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
}
