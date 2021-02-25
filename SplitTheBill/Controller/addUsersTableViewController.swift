//
//  addUsersTableViewController.swift
//  SplitTheBill
//
//  Created by Jaival Bhuptani on 2020-10-30.
//

import UIKit
import RealmSwift

class addUsersTableViewController: UIViewController{
    var realm = try! Realm()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userInput: UITextField!
    var eventObj : Event?
    override func viewDidLoad() {
        super.viewDidLoad()
//        tableView.tableFooterView = UIView(frame: .zero)
        tableView.delegate = self
        tableView.dataSource = self
        userInput.delegate = self
    }
    
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
                do{
                    try realm.write {
                        let c = Contributor()
                        c.name = userInput!.text ?? "NO User"
                        //c.bill = [String:Double]()
                        e.contributors.append(c)
                    }
                    
                }catch{
                    print("Cannot add contributor in the event \(error)")
                }
            }
        }
        userInput.text = ""
        tableView.reloadData()
    }
    
}
// MARK: - Table view methods
extension addUsersTableViewController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return eventObj?.contributors.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "user", for: indexPath)
        cell.textLabel?.text = eventObj?.contributors[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                if let c = eventObj?.contributors[indexPath.row]{
                    do{
                        try realm.write({
                            realm.delete(c)
                        })
                    }catch{
                        print("Cannot delete contributor")
                        
                    }
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
            
        }
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
