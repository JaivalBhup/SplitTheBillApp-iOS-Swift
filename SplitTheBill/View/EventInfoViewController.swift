//
//  EventInfoViewController.swift
//  SplitTheBill
//
//  Created by Jaival Bhuptani on 2021-03-13.
//

import UIKit
import Firebase
class EventInfoViewController: UIViewController {
    @IBOutlet weak var billContriSeg: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var label: UILabel!
    let db = Firestore.firestore()
    var eventID:String?
    var bills = [Bill]()
    var contributors = [Contributor]()
    var currItrator = [Any]()
    var currVal = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        currItrator = bills
        self.label.text = "Bills"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: .zero)
        // Do any additional setup after loading the view.
    }
    

    @IBAction func segChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.label.text = "Bills"
            currItrator = bills
            currVal = 0
            tableView.reloadData()
        case 1:
            self.label.text = "Contributors"
            currItrator = contributors
            currVal = 1
            tableView.reloadData()

        default:
            self.label.text = "Bills"
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension EventInfoViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        currItrator.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        if currVal == 0{
            let i = currItrator as! [Bill]
            cell.textLabel?.text = "$\(i[indexPath.row].amount) for \(i[indexPath.row].title)"
            cell.detailTextLabel?.text = "Paid By: \(i[indexPath.row].contributor)"
            cell.imageView?.image = UIImage(systemName: "text.chevron.right")
        }
        else{
            let i = currItrator as! [Contributor]
            cell.textLabel?.text = "\(i[indexPath.row].name)"
            cell.detailTextLabel?.text = "\(i[indexPath.row].email)"
            cell.imageView?.image = UIImage(systemName: "person")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // Add Deletion of the contributor.....
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if currVal == 0{
                if editingStyle == .delete {
                    let bill = currItrator as! [Bill]
                    let b = bill[indexPath.row]
                    let eventRef = db.collection("Events").document(eventID ?? "")
                    var total:Double = 0
                    eventRef.getDocument { (DocumentSnapshot, Error) in
                        if let s = DocumentSnapshot?.data(){
                            total = s["Total"] as! Double
                            let new = total - b.amount
                            eventRef.updateData(["Bills" : FieldValue.arrayRemove([[
                                "Amount": b.amount,
                                "Contributor":b.contributor,
                                "Title": b.title
                            ]])
                            ,
                            "Total":new
                            ])
                        }
                    }
                    currItrator.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }

            }
        }
    
}
