//
//  LoginViewController.swift
//  SplitTheBill
//
//  Created by Jaival Bhuptani on 2021-02-25.
//

import UIKit
import Firebase
class LoginViewController: UIViewController {

    @IBOutlet var email: UITextField!
    @IBOutlet weak var pass: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        setUpElements()
    }
    func setUpElements(){
        errorLabel.alpha = 0
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
}
