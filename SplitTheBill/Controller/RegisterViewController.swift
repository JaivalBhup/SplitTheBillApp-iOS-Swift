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
    
    @IBOutlet weak var errorLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
    }
    override func viewWillAppear(_ animated: Bool) {
        setUpElements()
    }
    func setUpElements(){
        errorLabel.alpha = 0
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
        if let e = email.text, let p = pass.text, let cp = cPass.text,let fn = fName.text, let ln = lName.text,let ph = phone.text{
            let e = e.trimmingCharacters(in: .whitespacesAndNewlines)
            let p = p.trimmingCharacters(in: .whitespacesAndNewlines)
            let cp = cp.trimmingCharacters(in: .whitespacesAndNewlines)
            let fn = fn.trimmingCharacters(in: .whitespacesAndNewlines)
            let ln = ln.trimmingCharacters(in: .whitespacesAndNewlines)
            let ph = ph.trimmingCharacters(in: .whitespacesAndNewlines)
            if e == "" || p == "" || cp == "" || fn == "" || ln == "" || ph == ""{
                errorLabel.alpha = 1
                errorLabel.text = "One or more fields are incomplete."
            }
            else{
                if p != cp{
                    errorLabel.alpha = 1
                    errorLabel.text = "Passwords don't match."
                }
                else{
                
                    Auth.auth().createUser(withEmail: e, password: p) { (authRes, error) in
                        if let err = error{
                            self.errorLabel.alpha = 1
                            self.errorLabel.text = err.localizedDescription
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
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! EventsViewController
        destination.userEmail = email.text ?? "eg@123.com"
    }
}
