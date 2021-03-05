//
//  addUsersTableViewController.swift
//  SplitTheBill
//
//  Created by Jaival Bhuptani on 2020-10-30.
//

import UIKit
import Firebase
class addUsersTableViewController: UIViewController{
    let db = Firestore.firestore()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userInput: UITextField!
    var eventObj : Event?
    var contributors:[Contributor]?
    override func viewDidLoad() {
        super.viewDidLoad()
        //loadContributors(for: eventObj!)
//        tableView.tableFooterView = UIView(frame: .zero)
        tableView.delegate = self
        tableView.dataSource = self
        userInput.delegate = self
    }
//    func loadContributors(for event : Event){
//        db.collection("EventContributor").whereField("EventID", isEqualTo: event.eventID).addSnapshotListener {
//            (QuerySnapshot, Error) in
//            self.contributors = []
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
//                                }
//                                DispatchQueue.main.async {
//                                    self.tableView.reloadData()
//                                }
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
//    }
    @IBAction func done(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    @IBAction func addUser(_ sender: UIButton) {
        add()
    }
    
    func add(){
        if userInput.text != ""{
            if let e = eventObj{
                let email = userInput.text
                db.collection("Contributors").document(email!).getDocument(completion: { (QuerySnapshot, Error) in
                    if let e = Error{
                        print(e)
                    }
                    else{
                        if let snapShot=QuerySnapshot{
                            self.db.collection("EventContributor").whereField("EventID", isEqualTo: e.eventID).whereField("ContributorID", isEqualTo: email!).getDocuments { (QuerySnapshot, Error) in
                                if let snapShots = QuerySnapshot?.documents{
                                    if snapShots.count > 0 {
                                        DispatchQueue.main.async {
                                            self.userInput.text = ""
                                            self.userInput.placeholder = "Already exists"
                                        }
                                    }
                                    else{
                                        if let _ = snapShot.data(){
                                            self.db.collection("EventContributor").addDocument(data:
                                                [
                                                    "EventID":e.eventID,
                                                    "ContributorID" :email!
                                                ]
                                            )
                                            let con = Contributor(name: "", email: email!)
                                            self.contributors?.append(con)
                                            self.tableView.reloadData()
                                        }
                                        else{
                                            DispatchQueue.main.async {
                                                self.userInput.text = ""
                                                self.userInput.placeholder = "Does not exists"
                                            }
                                        }
                                    }
                                }
                            }
                            
                        }
                        
                    }
                })
            }
        }
        userInput.text = ""
        
    }
    
}
// MARK: - Table view methods
extension addUsersTableViewController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return contributors?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "user", for: indexPath)
        cell.textLabel?.text = contributors?[indexPath.row].email
        return cell
    }
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//            if editingStyle == .delete {
//                if let c = eventObj?.contributors[indexPath.row]{
//                    do{
//                        try realm.write({
//                            realm.delete(c)
//                        })
//                    }catch{
//                        print("Cannot delete contributor")
//
//                    }
//                    tableView.deleteRows(at: [indexPath], with: .fade)
//                }
//            }
//
//        }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
//MARK:- UITextField
extension addUsersTableViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        add()
        textField.resignFirstResponder()
        return true
    }
}
