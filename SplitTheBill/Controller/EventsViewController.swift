//
//  ViewController.swift
//  SplitTheBill
//
//  Created by Jaival Bhuptani on 2020-10-29.
//

import UIKit
import Firebase

class EventsViewController: UITableViewController {
    var events = [Event]()
    var userEmail = ""
    let db = Firestore.firestore()
    var contributor = Contributor()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: .zero)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadContributor()
        loadEvents(for: userEmail)
        
    }
    
    func loadContributor(){
        db.collection("Contributors").document(userEmail).getDocument { (DocumentSnapshot, Error) in
            if let e = Error{
                print("User Does Not Exists \(e)")
            }
            else{
                let data = DocumentSnapshot?.data()
                let name = "\(data?["FirstName"] ?? "") \(data?["LastName"] ?? "")"
                self.contributor = Contributor(name: name, email: data!["Email"] as! String)
            }
        }
        
    }
    
    // Delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "GoToBill", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToBill"{
            let destination = segue.destination as! BillTableViewController
            if let indexPath = tableView.indexPathForSelectedRow{
                destination.event = events[indexPath.row]
            }
        }
        if segue.identifier == "GoToAddUser"{
            let destination = segue.destination as! addUsersTableViewController
            destination.eventObj = events.last
        }
    }
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//            if editingStyle == .delete {
//                if let event = self.events?[indexPath.row]{
//                    // remove all contributors
//                    for c in event.contributors{
//                        for b in c.bill{
//                            do{
//                                try realm.write({
//                                    realm.delete(b)
//                                })
//                            }catch{
//                                print("Cannot Delete Bill\(error)")
//                            }
//                        }
//                        do{
//                            try realm.write({
//                                realm.delete(c)
//                            })
//                        }catch{
//                            print("Cannot Delete Contributor\(error)")
//                        }
//                    }
//                    // remove event
//                    do{
//                        try realm.write({
//                            realm.delete(event)
//                        })
//                    }catch{
//                        print("Cannot Delete Event \(error)")
//                    }
//                    tableView.deleteRows(at: [indexPath], with: .fade)
//                }
//                
//            } else if editingStyle == .insert {
//                // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//            }
//        }
    

    // Datasource methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "event")!
        cell.textLabel?.text = events[indexPath.row].eventName
        cell.detailTextLabel?.text = "Total $\(events[indexPath.row].total)"
        return cell
    }
    
    
    @IBAction func addEvent(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert =  UIAlertController(title: "Add A New Event", message: "", preferredStyle: .alert)
        alert.addTextField { (alertTextfield) in
            textField = alertTextfield
        }
        
        let action1 = UIAlertAction(title: "Add", style: .default) { (alertAction) in
            let text = textField.text!
            if text != "" && text != " "{
                var e = Event()
                e.eventName = text
                self.save(e)
                //self.performSegue(withIdentifier: "GoToAddUser", sender: self)
            }
            self.tableView.reloadData()
        }
        alert.addAction(action1)
        present(alert, animated: true, completion: nil)
    }
    
    func loadEvents(for contributor: String){
//        print("in lOad events \(contributor)")
        let eventIDsRef = db.collection("EventContributor")
        eventIDsRef.whereField("ContributorID", isEqualTo: contributor).addSnapshotListener {
            (querySnapshot, err) in
            if let e = err{
                print("error \(e)")
            }
            else{
                if let snapshot = querySnapshot?.documents{
                    self.events = []
                    for doc in snapshot{
                        let eventContriDoc = doc.data()
                        let id = eventContriDoc["EventID"] as! String
                        self.db.collection("Events").document(id).getDocument { (DocumentSnapshot, Error) in
                            if let d = DocumentSnapshot?.data(){
                                print(d)
                                let eventName = d["EventName"] as! String
                                let total = d["Total"] as! Double
                                let id = d["id"] as! String
                                let event = Event(eventID : id,eventName: eventName, total: (total))
                                self.events.append(event)
                                DispatchQueue.main.async {
//                                    print("data reloaded")
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    }
                    
                }
               
            }
                
        }
    }
    func save(_ e: Event){
        events = []
        let eventDoc = db.collection("Events").document()
        eventDoc.setData([
            "EventName":e.eventName,
            "Total":0,
            "id":eventDoc.documentID
        ])
        db.collection("EventContributor").addDocument(data: [
            "EventID":eventDoc.documentID,
            "ContributorID" :contributor.email
        ])
    }
    

}

    
