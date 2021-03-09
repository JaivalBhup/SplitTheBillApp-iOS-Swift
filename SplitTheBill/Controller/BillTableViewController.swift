//
//  BillTableViewController.swift
//  SplitTheBill
//
//  Created by Jaival Bhuptani on 2020-10-29.
//

import UIKit
import Firebase
class BillTableViewController: UITableViewController{
    var event:Event?
    let db = Firestore.firestore()
    var contributors:[Contributor] = []
    var bills:[Bill] = []
    var conBills:[ContibutorToBills] = []
    var billAmts = [Double]()
    var individualPaymets = [Double]()
    var deletingContriInd = -1
    override func viewDidLoad() {
        super.viewDidLoad()
        title = event?.eventName ?? ""
        self.navigationItem.prompt = "Total: \(event?.total ?? 0)"
        billAmts = [Double](repeating: 0.0, count: contributors.count)
        individualPaymets = [Double](repeating: 0.0, count: contributors.count)
        //updateBillTotal()
    }
    override func viewWillAppear(_ animated: Bool) {
        loadContributors()
//        updateBillTotal()
    }
    func loadContributors(){
        db.collection("Events").document(event?.eventID ?? "").addSnapshotListener { (DocumentSnapshot, Error) in
            self.contributors = []
            if let snapShot = DocumentSnapshot?.data(){
                let contributors = snapShot["Contributors"] as! [String]
                for contri in contributors{
                    self.db.collection("Contributors").document(contri).getDocument { (DocumentSnapshot, Error) in
                        if let d = DocumentSnapshot?.data(){
                            let name = "\(d["FirstName"] ?? "") \(d["LastName"] ?? "")"
                            let contri = Contributor(name: name, email: d["Email"] as! String)
                            self.contributors.append(contri)
                            print(self.contributors)
                        }
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
            }
            self.load()
        }
    }
    func load(){
        db.collection("Events").document(event?.eventID ?? "").addSnapshotListener { (QuerySnapshot, Error) in
            if let e = Error{
                print(e)
            }
            else{
                let snapShot = QuerySnapshot?.data()
                if let data = snapShot{
                    let total = data["Total"] as! Double
                    self.event?.total=total
                    if let bills = data["Bills"] as? [[String:Any]]{
                        for bill in bills{
                            let title = bill["Title"]! as! String
                            let amt = bill["Amount"]! as! Double
                            let contributor = bill["Contributor"]! as! String
                            let bill = Bill(contributor: contributor, title: title, amount: amt)
                            self.bills.append(bill)
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.navigationItem.prompt = "Total: \(self.event?.total ?? 0)"
                    self.tableView.reloadData()
                }
            }
        }
//        db.collection("EventContributor").whereField("EventID", isEqualTo: event.eventID).addSnapshotListener { (QuerySnapshot, Error) in
//            self.contributors = []
//            self.conBills = []
//            if let e = Error{
//                print("Error getting new contributor\(e)")
//            }
//            else{
//                if let snapShot = QuerySnapshot?.documents{
//                    for document in snapShot{
//                        let data = document.data()
//                        let email = data["ContributorID"] as! String
//                        self.db.collection("Contributors").document(email).getDocument { (DocumentSnapshot, Error) in
//                            if let e = Error{
//                                print(e)
//                            }
//                            else{
//                                if let d = DocumentSnapshot?.data(){
//                                    let name = "\(d["FirstName"] ?? "") \(d["LastName"] ?? "")"
//                                    let contri = Contributor(name: name, email: d["Email"] as! String)
//                                    self.contributors.append(contri)
//                                    let cb = ContibutorToBills()
//                                    cb.contributor = contri
//                                    self.db.collection("Bills").whereField("EventID", isEqualTo: self.event?.eventID ?? "NoID").whereField("Contributor", isEqualTo: contri.email).getDocuments { (QuerySnapshot, Error) in
//                                        if let snapShots = QuerySnapshot?.documents{
//                                            for snapShot in snapShots{
//                                                let data = snapShot.data()
//                                                let id = data["id"] as! String
//                                                let title = data["Title"] as! String
//                                                let amt = data["Amount"] as! Double
//                                                let b = Bill(billID: id, title: title, amount: amt)
//                                                cb.Bills.append(b)
//                                            }
//                                        }
//                                    }
//                                    self.conBills.append(cb)
//                                    DispatchQueue.main.async {
//                                        self.updateBillTotal()
//                                        self.tableView.reloadData()
//                                    }
//                                }
//
//                            }
//
//
//                        }
//
//                    }
//
//                }
//            }
//        }
    }
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return contributors.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "Bill")!
        cell.textLabel?.text = contributors[indexPath.row].name
//        cell.detailTextLabel?.text = "\(Double(floor(100*billAmts[indexPath.row])/100)) CAD"
        return cell
    }
    
    // MARK: - Table view delegate methods
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
//    func deleteContributor(at: Int){
//        if let contri = event?.contributors[at]{
//            for b in contri.bill{
//                do{
//                    try realm.write({
//                        realm.delete(b)
//                    })
//                }catch{
//                    print(error)
//                }
//            }
//            do{
//                try realm.write({
//                    realm.delete(contri)
//                })
//            }catch{
//                print(error)
//            }
//
//        }
//        updateBillTotal()
//    }
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            deletingContriInd = indexPath.row
//            let alert =  UIAlertController(title: "Confirm Delete", message: "Are You sure you want to \(event?.contributors[indexPath.row].name ?? "No Name") from the bill", preferredStyle: .alert)
//            let action1 = UIAlertAction(title: "Delete", style: .default) { (alertAction) in
//                self.deleteContributor(at: indexPath.row)
//                tableView.deleteRows(at: [indexPath], with: .fade)
//                tableView.reloadData()
//            }
//            let action2 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//                tableView.reloadData()
//            alert.addAction(action1)
//            alert.addAction(action2)
//            present(alert, animated: true, completion: nil)
//            }
//
//        }
            
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if  (bills?.count ?? 0) > 0{
        performSegue(withIdentifier: "GoToUserBill", sender: self)
//        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToUserBill"{
            let destination = segue.destination as! UserBillTableViewController
            if let indexPath = tableView.indexPathForSelectedRow{
                let contri = contributors[indexPath.row]
                var conBills:[Bill] = []
                for b in bills{
                    if b.contributor == contri.email{
                        conBills.append(b)
                    }
                }
                destination.contributor = contri
                destination.bills = conBills
                    
            }
        }
        if segue.identifier == "AddBill"{
            let destination = segue.destination as! AddBillViewController
            destination.event = self.event
            destination.contributors = contributors
        }
        if segue.identifier == "settleUp"{
            let destination = segue.destination as! SettleUpViewController
            destination.billStandings = self.billAmts
            destination.contributors = self.contributors
        }
        if segue.identifier == "addContri"{
            let destination = segue.destination as! addUsersTableViewController
            destination.eventObj = event
            destination.contributors = contributors
        }
    }
    func updateBillTotal(){
        tableView.reloadData()
//        billAmts = [Double](repeating: 0.0, count: contributors.count )
//        individualPaymets = [Double](repeating: 0.0, count:contributors.count)
//        var m = 0.0
//        var j = 0
//        for cBill in conBills {
//            print(cBill, j)
//            for bill in cBill.Bills{
//                let amt = bill.amount
//                m+=amt
//                self.individualPaymets[j] += amt
//            }
//            j += 1
//
//        }
//        if let e = self.event{
//            self.db.collection("Events").document(e.eventID).setData([
//                "Total":m
//            ],merge: true)
//        }
//        self.event?.total = m
//        let split = m / Double(self.contributors.count)
//        print(split)
//        print(self.individualPaymets)
//        for b in 0..<self.billAmts.count{
//            self.billAmts[b] = self.individualPaymets[b] - split
//        }
//        print(self.billAmts)
//        self.navigationItem.prompt = "Total: \(self.event?.total ?? 0)"
//        self.tableView.reloadData()
//    }
//    @IBAction func addBill(_ sender: UIBarButtonItem) {
//        performSegue(withIdentifier: "AddBill", sender: self)
//    }
//
//    @IBAction func settleUp(_ sender: UIButton) {
//            performSegue(withIdentifier: "settleUp", sender: self)
        
    }
//
    @IBAction func refresh(_ sender: UIButton) {
        updateBillTotal()
    }
//
//
    
}
