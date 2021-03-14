//
//  AddBillViewController.swift
//  SplitTheBill
//
//  Created by Jaival Bhuptani on 2020-10-31.
//

import UIKit
import Firebase
class AddBillViewController: UIViewController{
    let db = Firestore.firestore()
    @IBOutlet weak var amountField: UITextField!
    @IBOutlet weak var titleField: UITextField!
    var event:Event?
    var contributors:[Contributor] = []
    var selectedContributor:Contributor?
    var selectedIndex = 0
    @IBOutlet weak var contributorPicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //loadContributors(for: event!)
        selectedContributor = contributors.first
        contributorPicker.delegate = self
        contributorPicker.dataSource = self
        amountField.delegate = self
        titleField.delegate = self

    }
    func loadContributors(for event : Event){
        db.collection("EventContributor").whereField("EventID", isEqualTo: event.eventID).getDocuments{ (QuerySnapshot, Error) in
            if let e = Error{
                print("Error getting new contributor\(e)")
            }
            else{
                if let snapShot = QuerySnapshot?.documents{
                    for document in snapShot{
                        let data = document.data()
                        let email = data["ContributorID"] as! String
                        self.db.collection("Contributors").document(email).getDocument { (DocumentSnapshot, Error) in
                            if let e = Error{
                                print(e)
                            }
                            else{
                                if let d = DocumentSnapshot?.data(){
                                    let name = "\(d["FirstName"] ?? "") \(d["LastName"] ?? "")"
                                    let contri = Contributor(name: name, email: d["Email"] as! String)
                                    self.contributors.append(contri)
                                }
                                DispatchQueue.main.async {
                                    self.selectedContributor = self.contributors.last
                                    self.contributorPicker.reloadAllComponents()
                                }
                            }
                            
                            
                        }
                    }
                }
               
            }
        }
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func add(Amount a: String, Text t: String, Contributor c: Contributor){
        let doc = db.collection("Events").document(event?.eventID ?? "")
        doc.updateData(["Bills":FieldValue.arrayUnion([[
            "Title":t,
            "Amount":Double(a) ?? 0,
            "Contributor":c.email
        ]])])
        var total = Double(a) ?? 0
        doc.getDocument { (DocumentSnapshot, Error) in
            if let data = DocumentSnapshot?.data(){
                let amt = data["Total"] as! Double
                total = total + amt
                doc.setData(["Total": total], merge: true)

            }
            
        }
        
    }

    @IBAction func AddBill(_ sender: UIButton) {
        if let a = amountField.text, let t = titleField.text, let c = selectedContributor{
            let alert = UIAlertController(title: "Confirm?", message: "\(c.name) paid \(a) for \(t)", preferredStyle: .alert)
            let action1 = UIAlertAction(title: "Yes", style: .default) { (UIAlertAction) in
                self.add(Amount: a, Text: t, Contributor: c)
            }
            let action2 = UIAlertAction(title: "No", style: .destructive) { (UIAlertAction) in
                return
            }
            alert.addAction(action1)
            alert.addAction(action2)
            self.present(alert, animated: true, completion: nil)
            
        }
    }
}

//MARK:- UIPicker methods
extension AddBillViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return contributors.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return contributors[row].name
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedIndex = row
        selectedContributor = contributors[row]
    }
}

//MARK:- UItextfield methods
extension AddBillViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
