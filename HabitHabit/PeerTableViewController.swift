//
//  PeerTableViewController.swift
//  HabitHabit-Zach
//
//  Created by Zach on 3/26/21.
//

import UIKit
import FirebaseDatabase

protocol DeleteFriendHabitFromTableDelegate {
    func deleteFriendHabitFromTable(index: Int) -> Void
}

class PeerTableViewController: UITableViewController, DeleteFriendHabitFromTableDelegate {
    @IBOutlet var peerTableView: UITableView!
    
    let peerCell = "PeerCell"
    let imageMagnificationSegue: String = "imageMagnificationSegueIdentifier"
    var friendHabits: [NameHabit] = []
    private let database: DatabaseReference = Database.database().reference()
    private let databaseUsernameKey: String = UserDefaults.standard.string(forKey: "kUsername") ?? "USERNAME_DATABASE_KEY_ERROR"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.habit.purple
        self.peerTableView.delegate = self
        self.peerTableView.dataSource = self
        self.setupRefreshControl()
        if UtilityClass.firstTimeSeeingPeerScreen {
            UtilityClass.firstTimeSeeingPeerScreen = false
            self.friendHabits = UtilityClass.initialFriendHabits
            self.peerTableView.reloadData()
        } else {
            self.setupFriendHabits()
        }
    }
    
    private func setupRefreshControl() -> Void {
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(self.updateFriendHabits(_:)), for: .valueChanged)
        self.refreshControl?.tintColor = .white
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Fetching Friend Habits ...")
        self.peerTableView.refreshControl = self.refreshControl
    }
    
    @objc private func updateFriendHabits(_ sender: Any) {
        self.setupFriendHabits()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friendHabits.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.peerTableView.dequeueReusableCell(withIdentifier: self.peerCell, for: indexPath as IndexPath) as! PeerTableViewCell
        cell.imageView?.image = self.friendHabits[indexPath.row].getImage()
        cell.usernameLabel?.text = "\(self.friendHabits[indexPath.row].username)"
        cell.habitLabel?.text = "\(self.friendHabits[indexPath.row].habitName)"
        // cell.accessoryType = .disclosureIndicator
        UIDesign.setCellProperties(cell: cell)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // this will turn on `masksToBounds` just before showing the cell
        cell.contentView.layer.masksToBounds = true
        let radius = cell.contentView.layer.cornerRadius
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: radius).cgPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: self.imageMagnificationSegue, sender: (self.friendHabits[indexPath.row], indexPath.row))
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func deleteFriendHabitFromTable(index: Int) {
        self.friendHabits.remove(at: index)
        self.peerTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.imageMagnificationSegue,
           let destination = segue.destination as? ImageMagnificationViewController {
            let (friendHabit, index): (NameHabit, Int) = sender as! (NameHabit, Int)
            destination.friendHabit = friendHabit
            destination.indexInTable = index
            destination.deletionDelegate = self
        }
    }
    
    private func setupFriendHabits() -> Void {
        self.friendHabits.removeAll()
        self.peerTableView.reloadData()
        self.database.child(self.databaseUsernameKey).child("Friends").observeSingleEvent(of: .value) {
            snapshotFriend in
            for case let childFriend as DataSnapshot in snapshotFriend.children {
                guard let friend = childFriend.value as? String else { return }
                
                self.database.child(friend).child("Private").getData{ (error, snapshot) in
                    var isPrivate = false
                    if let error = error {
                        print("Error getting data \(error)")
                    }
                    else if snapshot.exists() {
                        isPrivate = snapshot.value as? Bool ?? false
                    }
                    if !isPrivate {
                        self.database.child(friend).child("Habit").observeSingleEvent(of: .value) {
                            snapshotHabit in
                            for case let childHabit as DataSnapshot in snapshotHabit.children {
                                guard let habitValue = childHabit.value as? [String: String] else { return }
                                let (habitExists, habit): (Bool, Habit?) = UtilityClass.makeHabit(value: habitValue)
                                if habitExists {
                                    for index in 0..<habit!.uncheckedImageUrls.count {
                                        self.friendHabits.append(NameHabit(username: friend, habitName: habit!.habit, imageUrl: habit!.uncheckedImageUrls[index], date: habit!.uncheckedDates[index], habit: habit!))
                                        self.peerTableView.reloadData()
                                    }
                                }
                            }
                        }
                    }
                }
            }
            self.refreshControl?.endRefreshing()
        }
    }
}
