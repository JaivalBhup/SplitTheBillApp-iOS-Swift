//
//  BillTableViewController.swift
//  SplitTheBill
//
//  Created by Jaival Bhuptani on 2020-10-29.
//

import UIKit
import Firebase
class BillTableViewController: UITableViewController{

    @IBOutlet weak var infoBut: UIButton!
    @IBOutlet weak var setUpBut: UIButton!
    @IBOutlet weak var addBut: UIButton!
    
    var event:Event?
    let db = Firestore.firestore()
    var contributors:[Contributor] = []
    var bills:[Bill] = []
    var conBills:[ContibutorToBills] = []
    var billAmts = [Double]()
    var individualPaymets = [Double]()
    var deletingContriInd = -1
    override func viewDidLoad() {
        setUpButtons()
        super.viewDidLoad()
        title = event?.eventName ?? ""
        self.navigationItem.prompt = "Total: \(event?.total ?? 0)"
        billAmts = [Double](repeating: 0.0, count: contributors.count)
        individualPaymets = [Double](repeating: 0.0, count: contributors.count)
        //updateBillTotal()
    }
    func setUpButtons(){
        infoBut.clipsToBounds = true
        infoBut.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        infoBut.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        infoBut.layer.shadowOpacity = 1.0;
        infoBut.layer.shadowRadius = 2.0;
        infoBut.layer.masksToBounds = false;
        infoBut.layer.cornerRadius = 4.0;
        
        setUpBut.clipsToBounds = true
        setUpBut.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        setUpBut.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        setUpBut.layer.shadowOpacity = 1.0;
        setUpBut.layer.shadowRadius = 2.0;
        setUpBut.layer.masksToBounds = false;
        setUpBut.layer.cornerRadius = 4.0;
        
        addBut.clipsToBounds = true
        addBut.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        addBut.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        addBut.layer.shadowOpacity = 1.0;
        addBut.layer.shadowRadius = 2.0;
        addBut.layer.masksToBounds = false;
        addBut.layer.cornerRadius = 4.0;
    }
    override func viewWillAppear(_ animated: Bool) {
        loadContributors(completion: load)
    }
    func loadContributors(completion: @escaping ()->Void){
        db.collection("Events").document(event?.eventID ?? "").addSnapshotListener { (DocumentSnapshot, Error) in
            self.contributors = []
            if let snapShot = DocumentSnapshot?.data(){
                let contributors = snapShot["Contributors"] as! [String]
                for contri in contributors{
                    self.db.collection("Contributors").document(contri).getDocument { (DocumentSnapshot, Error) in
                        if let d = DocumentSnapshot?.data(){
                            let name = "\(d["FirstName"] ?? "") \(d["LastName"] ?? "")"
                            let contri = Contributor(name: name, email: d["Email"] as! String)
                            if !self.contributors.contains(where: {$0.email == contri.email}){
                                self.contributors.append(contri)
                            }
//                            print(self.contributors)
                        }
                        self.tableView.reloadData()
                        completion()
                    }
                }
            
            }
        
        }
    }
    func load(){
        db.collection("Events").document(event?.eventID ?? "").getDocument{ (QuerySnapshot, Error) in
            self.bills = []
            if let e = Error{
                print(e)
            }
            else{
                let snapShot = QuerySnapshot?.data()
                if let data = snapShot{
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
                self.updateBillTotal()
            }
        }
    }
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return contributors.count
    }
    
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "Bill")!
        cell.textLabel?.text = contributors[indexPath.row].name
        if billAmts.count > 0{
            cell.detailTextLabel?.text = "\(Double(floor(100*billAmts[indexPath.row])/100)) CAD"
        }
        else{
            cell.detailTextLabel?.text = "..."
        }
        return cell
    }
    
    // MARK: - Table view delegate methods
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
            
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
        if segue.identifier == "GoToInfo"{
            let destination = segue.destination as! EventInfoViewController
            destination.contributors = contributors
            destination.bills = bills
            destination.eventID = event?.eventID
        }
    }
    // Optimize.......
    func updateBillTotal(){
        //tableView.reloadData()
        billAmts = [Double](repeating: 0.0, count: contributors.count )
        individualPaymets = [Double](repeating: 0.0, count:contributors.count)
        var m = 0.0
        var j = 0
//        print(bills, "bills")
//        print(contributors, "bills")
        for con in contributors{
            for b in bills{
                if b.contributor == con.email{
                    let amt = b.amount
                    self.individualPaymets[j] += amt
                    
                    m+=amt
                }
                
            }
            j += 1
        }
        self.event?.total = m
        let split = m / Double(self.contributors.count)
//        print(split)
//        print(self.individualPaymets)
        for b in 0..<self.billAmts.count{
            self.billAmts[b] = self.individualPaymets[b] - split
        }
//        print(self.billAmts)
        self.navigationItem.prompt = "Total: \(self.event?.total ?? 0)"
        self.tableView.reloadData()
    }
//
    @IBAction func settleUp(_ sender: UIButton) {
            performSegue(withIdentifier: "settleUp", sender: self)
        
    }

//    @IBAction func refresh(_ sender: UIButton) {
//        updateBillTotal()
//   }
    
    
    @IBAction func goToInfo(_ sender: UIButton) {
        performSegue(withIdentifier: "GoToInfo", sender: self)
    }
    //
//
    
}
