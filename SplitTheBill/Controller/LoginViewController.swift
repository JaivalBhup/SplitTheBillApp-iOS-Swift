//
//  LoginViewController.swift
//  SplitTheBill
//
//  Created by Jaival Bhuptani on 2021-02-25.
//

import UIKit
import Firebase
class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var email: UITextField!
    @IBOutlet weak var pass: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
        email.delegate = self
        pass.delegate = self
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        setUpElements()
    }
    func setUpElements(){
        errorLabel.alpha = 0
//        loginButton.layer.cornerRadius = 30
        loginButton.clipsToBounds = true
        loginButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        loginButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        loginButton.layer.shadowOpacity = 1.0;
        loginButton.layer.shadowRadius = 2.0;
        loginButton.layer.masksToBounds = false;
        loginButton.layer.cornerRadius = 4.0;
        email.attributedPlaceholder = NSAttributedString(string: "Enter email...",
                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor(displayP3Red: 87, green: 101, blue: 116, alpha: 1.0)])
        pass.attributedPlaceholder = NSAttributedString(string: "Enter password...",
                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor(displayP3Red: 87, green: 101, blue: 116, alpha: 1.0)])

        
    }
    @IBAction func Login(_ sender: UIButton) {
        if let e = email.text, let p = pass.text{
            let email = e.trimmingCharacters(in: .whitespacesAndNewlines)
            let pass = p.trimmingCharacters(in: .whitespacesAndNewlines)
            Auth.auth().signIn(withEmail: email, password: pass) { (authRes, error) in
                if let e = error{
                    print("error \(e)")
                    self.errorLabel.alpha = 1
                    self.errorLabel.text = e.localizedDescription
                }
                else{
                    self.performSegue(withIdentifier: "LoginToEvent", sender: self)
                }
            }
    }
       
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? EventsViewController{
            destination.userEmail = email.text ?? "eg@123.com"
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
