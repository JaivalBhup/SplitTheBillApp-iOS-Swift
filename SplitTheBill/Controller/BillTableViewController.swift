//
//  BillTableViewController.swift
//  SplitTheBill
//
//  Created by Jaival Bhuptani on 2020-10-29.
//

import UIKit
import RealmSwift

class BillTableViewController: UITableViewController{
    var realm = try! Realm()
    var event:Event?
    var billAmts = [Double]()
    var individualPaymets = [Double]()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = event?.eventName
        self.navigationItem.prompt = "Total: \(event?.total ?? 0)"
        billAmts = [Double](repeating: 0.0, count: event?.contributors.count ?? 0)
        individualPaymets = [Double](repeating: 0.0, count: event?.contributors.count ?? 0)
        updateBillTotal()
    }
    override func viewWillAppear(_ animated: Bool) {
        updateBillTotal()
        tableView.reloadData()
    }
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return event?.contributors.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "Bill")!
        cell.textLabel?.text = event?.contributors[indexPath.row].name
        cell.detailTextLabel?.text = "\(billAmts[indexPath.row]) INR"
        return cell
    }
    
    // MARK: - Table view delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if  (event?.contributors[indexPath.row].bill.count ?? 0) > 0{
            performSegue(withIdentifier: "GoToUserBill", sender: self)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToUserBill"{
            let destination = segue.destination as! UserBillTableViewController
            if let indexPath = tableView.indexPathForSelectedRow{
                destination.contributor = event?.contributors[indexPath.row]
                    
            }
        }
        if segue.identifier == "AddBill"{
            let destination = segue.destination as! AddBillViewController
            destination.event = self.event
        }
        if segue.identifier == "settleUp"{
            let destination = segue.destination as! SettleUpViewController
            destination.billStandings = self.billAmts
            destination.contributor = self.event!.contributors
        }
    }
    func updateBillTotal(){
        billAmts = [Double](repeating: 0.0, count: event?.contributors.count ?? 0)
        individualPaymets = [Double](repeating: 0.0, count: event?.contributors.count ?? 0)
        var m = 0.0
        if let cs = event?.contributors{
            var j = 0
            for i in cs {
                for b in i.bill{
                    m += b.amount
                    individualPaymets[j] += b.amount
                }
                j += 1
            }
        }
        do{
            try realm.write({
                event?.total = m
            })
        }catch{
            print("EErrrrr \(error)")
        }
        
        let split = m / Double(event?.contributors.count ?? 1)
        for b in 0..<billAmts.count{
            billAmts[b] = individualPaymets[b] - split
        }
        self.navigationItem.prompt = "Total: \(event?.total ?? 0)"
    }
    @IBAction func addBill(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "AddBill", sender: self)
    }
    
    @IBAction func settleUp(_ sender: UIButton) {
            performSegue(withIdentifier: "settleUp", sender: self)
    }
    
    
}
