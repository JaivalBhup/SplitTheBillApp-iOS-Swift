//
//  SettleUpViewController.swift
//  SplitTheBill
//
//  Created by Jaival Bhuptani on 2020-10-31.
//

import UIKit

class SettleUpViewController: UITableViewController {
    var billStandings=[Double]()
    var contributors:[Contributor]?
    var owings = [[String]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: .zero)
        print(billStandings)
        for i in 0..<(billStandings.count){
            if billStandings[i] > 0 {
                var j = 0
                while billStandings[i] != 0 && j < billStandings.count{
                    if i != j && billStandings[j] < 0{
                        if abs(billStandings[i]) < abs(billStandings[j]){
                            let a = billStandings[i]
                            billStandings[j] += billStandings[i]
                            billStandings[i] = 0
                            owings.append(["\(contributors?[j].name ?? "")","\(contributors?[i].name ?? "")","\(abs(a))"])
                        }
                        else if abs(billStandings[i]) > abs(billStandings[j]){
                            let a = billStandings[j]
                            billStandings[i] += billStandings[j]
                            billStandings[j] = 0
                            owings.append(["\(contributors?[j].name ?? "")","\(contributors?[i].name ?? "")","\(abs(a))"])
                        }
                        else if abs(billStandings[i]) == abs(billStandings[j]) && abs(billStandings[i]) != 0 && abs(billStandings[j]) != 0{
                            let a = billStandings[i]
                            billStandings[i] = 0
                            billStandings[j] = 0
                            owings.append(["\(contributors?[j].name ?? "")","\(contributors?[i].name ?? "")","\(abs(a))"])
                        }
                    }
                    j += 1
                }
            }
        }
        print(owings)
        
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return owings.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settleCell", for: indexPath)
        cell.textLabel?.text = "\(owings[indexPath.row][0]) owes \(owings[indexPath.row][1])"
        cell.detailTextLabel?.text = "\(owings[indexPath.row][2]) CAD"
        return cell
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                tableView.deleteRows(at: [indexPath], with: .fade)
                }
        }
            
}
