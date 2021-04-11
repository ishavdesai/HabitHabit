//
//  PeerTableViewController.swift
//  HabitHabit-Zach
//
//  Created by Zach on 3/26/21.
//

import UIKit

var peerHabitList:[Habit] = []

protocol peerHabitDeleter {
    func deleteFromPeerList(row: Int)
}

class PeerTableViewController: UITableViewController, peerHabitDeleter {

    @IBOutlet var peerTableView: UITableView!
    
    let peerCell = "PeerCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.tabBarItem.image = UIImage(named: "item")
        //self.tabBarItem.selectedImage = UIImage(named: "item_selected")
        // Do any additional setup after loading the view.
        
        peerTableView.delegate = self
        peerTableView.dataSource = self
        
        peerHabitList.append(Habit(habit: "bob", streak: 4, dates: []))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.peerTableView.reloadData()
    }
    
    // load peers' habit information which the user has not approved/denied yet.
    func loadPeerHabits() {
        // retrieve current user's friends' IDs
        
        // for each user, retrieve user's info and create a habit object, and append it to the peerHabitList
        // if it is not approved/denied by the user yet
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        peerHabitList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: peerCell, for: indexPath as IndexPath) as! PeerTableViewCell
        let row = indexPath.row
        cell.imageButton.tag = row
        cell.checkButton.tag = row
        cell.denyButton.tag = row
//        cell.imageButton.setImage(peerHabitList[row].image, for: .normal)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }

    @IBAction func imagePressed(_ sender: Any) {
        self.performSegue(withIdentifier: "imageMagnificationSegueIdentifier", sender: (sender as AnyObject).tag)
    }
    
    @IBAction func checkPressed(_ sender: Any) {
        // that habit's approved count is incremented and the table view cell disappear
        peerHabitList.remove(at: (sender as AnyObject).tag)
        self.peerTableView.reloadData()
    }
    
    @IBAction func denyPressed(_ sender: Any) {
        // that habit's deny count is incremented and the table view cell disappear
        peerHabitList.remove(at: (sender as AnyObject).tag)
        self.peerTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "imageMagnificationSegueIdentifier",
           let nextVC = segue.destination as? ImageMagnificationViewController {
            let row = sender as! Int
            nextVC.peerObject = peerHabitList[row]
            nextVC.row = row
        }
    }
    
    func deleteFromPeerList(row: Int) {
        peerHabitList.remove(at: row)
        self.peerTableView.reloadData()
    }
    
}
