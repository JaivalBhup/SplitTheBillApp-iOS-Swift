//
//  addUsersTableViewController.swift
//  SplitTheBill
//
//  Created by Jaival Bhuptani on 2020-10-30.
//

import UIKit
import Firebase
class addUsersTableViewController: UIViewController{
    let db = Firestore.firestore()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userInput: UITextField!
    var eventObj : Event?
    var contributors:[Contributor]?
    override func viewDidLoad() {
        super.viewDidLoad()
        //loadContributors(for: eventObj!)
//        tableView.tableFooterView = UIView(frame: .zero)
        tableView.delegate = self
        tableView.dataSource = self
        userInput.delegate = self
        userInput.attributedPlaceholder = NSAttributedString(string: "Enter email...",
                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor(displayP3Red: 87, green: 101, blue: 116, alpha: 1.0)])
    }
//    func loadContributors(for event : Event){
//        db.collection("EventContributor").whereField("EventID", isEqualTo: event.eventID).addSnapshotListener {
//            (QuerySnapshot, Error) in
//            self.contributors = []
//            if let e = Error{
//                print("Error getting new contributor\(e)")
//            }
//            else{
//                if let snapShot = QuerySnapshot?.documents{
//                    for document in snapShot{
//                        let data = document.data()
//                        let email = data["ContributorID"] as! String
//                        self.db.collection("Contributors").document(email).getDocument { (DocumentSnapshot, Error) in
//                            if let e = Error{
//                                print(e)
//                            }
//                            else{
//                                if let d = DocumentSnapshot?.data(){
//                                    let name = "\(d["FirstName"] ?? "") \(d["LastName"] ?? "")"
//                                    let contri = Contributor(name: name, email: d["Email"] as! String)
//                                    self.contributors.append(contri)
//                                }
//                                DispatchQueue.main.async {
//                                    self.tableView.reloadData()
//                                }
//                            }
//
//
//                        }
//
//                    }
//
//                }
//            }
//        }
//    }
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
                let email = userInput.text
                db.collection("Contributors").document(email!).getDocument(completion: { (QuerySnapshot, Error) in
                    if let e = Error{
                        print(e)
                    }
                    else{
                        if let _ = QuerySnapshot{
                            self.db.collection("Events").document(e.eventID).getDocument{ (QuerySnapshot, Error) in
                                if let data = QuerySnapshot?.data(){
                                    let contris = data["Contributors"] as! [String]
                                    if contris.contains(email ?? ""){
                                        DispatchQueue.main.async {
                                            self.userInput.text = ""
                                            self.userInput.placeholder = "Already exists"
                                        }
                                    }
                                    else{
                                        self.db.collection("Contributors").document(email ?? "").getDocument { (DocumentSnapshot, Error) in
                                            if let e = Error{
                                                print(e)
                                            }
                                            else{
                                                if let _ = DocumentSnapshot?.data(){
                                                    self.db.collection("Events").document(e.eventID).updateData(["Contributors": FieldValue.arrayUnion([email!])])
                                                    let c = Contributor(name: "", email: email!)
                                                    self.userInput.text = ""
                                                    self.userInput.placeholder = ""
                                                    self.contributors?.append(c)
                                                    self.tableView.reloadData()
                                                }
                                                else{
                                                    DispatchQueue.main.async {
                                                        self.userInput.text = ""
                                                        self.userInput.placeholder = "Does not exists"
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                        }
                        
                    }
                })
            }
        }
        userInput.text = ""
        
    }
    
}
// MARK: - Table view methods
extension addUsersTableViewController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return contributors?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "user", for: indexPath)
        cell.textLabel?.text = contributors?[indexPath.row].email
        return cell
    }
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//            if editingStyle == .delete {
//                if let c = eventObj?.contributors[indexPath.row]{
//                    do{
//                        try realm.write({
//                            realm.delete(c)
//                        })
//                    }catch{
//                        print("Cannot delete contributor")
//
//                    }
//                    tableView.deleteRows(at: [indexPath], with: .fade)
//                }
//            }
//
//        }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//            let cornerRadius : CGFloat = 10.0
//            cell.backgroundColor = UIColor.clear
//            let layer: CAShapeLayer = CAShapeLayer()
//            let pathRef:CGMutablePath = CGMutablePath()
//            let bounds: CGRect = cell.bounds.insetBy(dx:0,dy:0)
//            var addLine: Bool = false
//
//            if (indexPath.row == 0 && indexPath.row == tableView.numberOfRows(inSection: indexPath.section)-1) {
//                pathRef.addRoundedRect(in: bounds, cornerWidth: cornerRadius, cornerHeight: cornerRadius)
//                // CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius)
//            } else if (indexPath.row == 0) {
//
//                pathRef.move(to: CGPoint(x: bounds.minX, y: bounds.maxY))
//                pathRef.addArc(tangent1End: CGPoint(x: bounds.minX, y: bounds.minY), tangent2End: CGPoint(x: bounds.midX, y: bounds.midY), radius: cornerRadius)
//                pathRef.addArc(tangent1End: CGPoint(x: bounds.maxX, y: bounds.minY), tangent2End: CGPoint(x: bounds.maxX, y: bounds.midY), radius: cornerRadius)
//                pathRef.addLine(to:CGPoint(x: bounds.maxX, y: bounds.maxY) )
//
//                addLine = true
//            } else if (indexPath.row == tableView.numberOfRows(inSection: indexPath.section)-1) {
//
//
//                pathRef.move(to: CGPoint(x: bounds.minX, y: bounds.minY), transform: CGAffineTransform())
//                //                    CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds))
//                pathRef.addArc(tangent1End: CGPoint(x: bounds.minX, y: bounds.maxY), tangent2End: CGPoint(x: bounds.midX, y: bounds.maxY), radius: cornerRadius)
//                pathRef.addArc(tangent1End: CGPoint(x: bounds.maxX, y: bounds.maxY), tangent2End: CGPoint(x: bounds.maxX, y: bounds.midY), radius: cornerRadius)
//                pathRef.addLine(to:CGPoint(x: bounds.maxX, y: bounds.minY) )
//
//
//            } else {
//                pathRef.addRect(bounds)
//
//                addLine = true
//            }
//
//            layer.path = pathRef
//            layer.fillColor = UIColor(red: 28/255.0, green: 28/255.0, blue: 31/255.0, alpha: 0.8).cgColor
//
//            if (addLine == true) {
//                let lineLayer: CALayer = CALayer()
//                let lineHeight: CGFloat = (1.0 / UIScreen.main.scale)
//                lineLayer.frame = CGRect(x:bounds.minX + 10 , y:bounds.size.height-lineHeight, width:bounds.size.width-10, height:lineHeight)
//                lineLayer.backgroundColor = tableView.separatorColor?.cgColor
//                layer.addSublayer(lineLayer)
//            }
//            let testView: UIView = UIView(frame: bounds)
//            testView.layer.insertSublayer(layer, at: 0)
//            testView.backgroundColor = UIColor.clear
//            cell.backgroundView = testView
//
//        }
    
}
//MARK:- UITextField
extension addUsersTableViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        add()
        textField.resignFirstResponder()
        return true
    }
}
