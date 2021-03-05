//
//  UserBillTableViewController.swift
//  SplitTheBill
//
//  Created by Jaival Bhuptani on 2020-10-30.
//

import UIKit
import Firebase
class UserBillTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    let db = Firestore.firestore()
    var bills : [Bill] = []
    var eventId:String?
    var contributor : Contributor?
    @IBOutlet weak var NameLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadBills(forConributor: contributor!, andEventID: eventId!)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: .zero)
        NameLabel.text = contributor?.name
    }
    
    func loadBills(forConributor c : Contributor, andEventID id: String){
        db.collection("Bills").whereField("EventID", isEqualTo: id).whereField("Contributor", isEqualTo: contributor?.email ?? "").getDocuments { (QuerySnapshot, Error) in
            if let snapShot = QuerySnapshot?.documents{
                for document in snapShot{
                    let data = document.data()
                    let amt = data["Amount"] as! Double
                    let billID = data["id"] as! String
                    let title = data["Title"] as! String
                    let bill = Bill(billID: billID, title: title, amount: amt)
                    self.bills.append(bill)
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
    }
    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return bills.count
    }
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "UserBill", for: indexPath)
        cell.textLabel?.text = bills[indexPath.row].title
        cell.detailTextLabel?.text = "\(bills[indexPath.row].amount) CAD"
        
        return cell
    }
    
    //MARK:- table view delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//            if editingStyle == .delete {
//                if let bill = contributor?.bill[indexPath.row]{
//                    do{
//                        try realm.write({
//                            realm.delete(bill)
//                        })
//                    }catch{
//                        print(error)
//                    }
//                    tableView.deleteRows(at: [indexPath], with: .fade)
//                    tableView.reloadData()
//                    }
//                }
//    }
}
