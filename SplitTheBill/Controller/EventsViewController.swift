//
//  ViewController.swift
//  SplitTheBill
//
//  Created by Jaival Bhuptani on 2020-10-29.
//

import UIKit
import RealmSwift

class EventsViewController: UITableViewController {
    let realm = try! Realm()
    var events:Results<Event>?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: .zero)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        load()
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
                destination.event = events?[indexPath.row]
            }
        }
        if segue.identifier == "GoToAddUser"{
            let destination = segue.destination as! addUsersTableViewController
            destination.eventObj = events?.last
        }
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                if let event = self.events?[indexPath.row]{
                    // remove all contributors
                    for c in event.contributors{
                        for b in c.bill{
                            do{
                                try realm.write({
                                    realm.delete(b)
                                })
                            }catch{
                                print("Cannot Delete Bill\(error)")
                            }
                        }
                        do{
                            try realm.write({
                                realm.delete(c)
                            })
                        }catch{
                            print("Cannot Delete Contributor\(error)")
                        }
                    }
                    // remove event
                    do{
                        try realm.write({
                            realm.delete(event)
                        })
                    }catch{
                        print("Cannot Delete Event \(error)")
                    }
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
                
            } else if editingStyle == .insert {
                // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            }
        }
    

    // Datasource methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "event")!
        cell.textLabel?.text = events?[indexPath.row].eventName ?? "Add A New Event."
        cell.detailTextLabel?.text = "\(events?[indexPath.row].contributors.count ?? 0) Contributers"
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
                let e = Event()
                e.eventName = text
                self.save(e)
                self.performSegue(withIdentifier: "GoToAddUser", sender: self)
            }
            self.tableView.reloadData()
        }
        alert.addAction(action1)
        present(alert, animated: true, completion: nil)
    }
    
    func load(){
        events = realm.objects(Event.self)
        tableView.reloadData()
    }
    func save(_ e: Event){
        do{
           try realm.write {
                realm.add(e)
            }
        }catch{
            print("Events Cannot be saved to realm \(error)")
        }
        tableView.reloadData()
    }
    

}

    
