//
//  RegisterViewController.swift
//  SplitTheBill
//
//  Created by Jaival Bhuptani on 2021-02-25.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController, UITextFieldDelegate {
    let db = Firestore.firestore()
    @IBOutlet weak var fName: UITextField!
    @IBOutlet weak var lName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var pass: UITextField!
    @IBOutlet weak var cPass: UITextField!
    
    @IBOutlet weak var signUp: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        fName.delegate = self
        lName.delegate = self
        email.delegate = self
        phone.delegate = self
        pass.delegate = self
        cPass.delegate = self
        setUpElements()
    }
    override func viewWillAppear(_ animated: Bool) {
        setUpElements()
    }
    func setUpElements(){
        errorLabel.alpha = 0
        signUp.layer.cornerRadius = 30
        signUp.clipsToBounds = true
        signUp.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        signUp.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        signUp.layer.shadowOpacity = 1.0;
        signUp.layer.shadowRadius = 2.0;
        signUp.layer.masksToBounds = false;
        signUp.layer.cornerRadius = 4.0;
        
        fName.attributedPlaceholder = NSAttributedString(string: "First Name",
                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor(displayP3Red: 87, green: 101, blue: 116, alpha: 1.0)])
        lName.attributedPlaceholder = NSAttributedString(string: "Last Name",
                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor(displayP3Red: 87, green: 101, blue: 116, alpha: 1.0)])
        email.attributedPlaceholder = NSAttributedString(string: "Email",
                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor(displayP3Red: 87, green: 101, blue: 116, alpha: 1.0)])
        phone.attributedPlaceholder = NSAttributedString(string: "(000)-000-0000",
                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor(displayP3Red: 87, green: 101, blue: 116, alpha: 1.0)])
        pass.attributedPlaceholder = NSAttributedString(string: "Password",
                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor(displayP3Red: 87, green: 101, blue: 116, alpha: 1.0)])
        cPass.attributedPlaceholder = NSAttributedString(string: "Retype password",
                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor(displayP3Red: 87, green: 101, blue: 116, alpha: 1.0)])
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
