//
//  AddBillViewController.swift
//  SplitTheBill
//
//  Created by Jaival Bhuptani on 2020-10-31.
//

import UIKit
import RealmSwift

class AddBillViewController: UIViewController{

    let realm = try! Realm()
    
    @IBOutlet weak var amountField: UITextField!
    @IBOutlet weak var titleField: UITextField!
    var event:Event?
    var selectedContributor:Contributor?
    @IBOutlet weak var contributorPicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contributorPicker.delegate = self
        contributorPicker.dataSource = self
        selectedContributor = event?.contributors.first
        amountField.delegate = self
        titleField.delegate = self

    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    @IBAction func AddBill(_ sender: UIButton) {
        if let a = amountField.text, let t = titleField.text, let c = selectedContributor{
            do{
                try realm.write({ 
                    let bill = Bill()
                    bill.amount = Double(a) ?? 0.0
                    bill.title = t
                    c.bill.append(bill)
                })
            }catch{
                print("Error while adding a bill \(error)")
            }
            dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

//MARK:- UIPicker methods
extension AddBillViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return event?.contributors.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return event?.contributors[row].name
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedContributor = event?.contributors[row]
    }
}

//MARK:- UItextfield methods
extension AddBillViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
