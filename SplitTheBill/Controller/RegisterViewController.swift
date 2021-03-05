//
//  RegisterViewController.swift
//  SplitTheBill
//
//  Created by Jaival Bhuptani on 2021-02-25.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    let db = Firestore.firestore()
    @IBOutlet weak var fName: UITextField!
    @IBOutlet weak var lName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var pass: UITextField!
    @IBOutlet weak var cPass: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func register(_ sender: UIButton) {
        if let e = email.text, let p = pass.text,let fn = fName.text, let ln = lName.text,let ph = phone.text{
            Auth.auth().createUser(withEmail: e, password: p) { (authRes, error) in
                if let err = error{
                    print("error creating user \(err)")
                }
                else{
                    self.db.collection("Contributors").document(e).setData(
                                                        ["FirstName":fn,
                                                         "LastName":ln,
                                                         "Email":e,
                                                         "Phone":ph,
                                                        ]) { (error) in
                                                        print(error ?? "")
                                            }
                    
                    self.performSegue(withIdentifier: "RegisterToEvent", sender: self)
                    
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! EventsViewController
        destination.userEmail = email.text ?? "eg@123.com"
    }
}
