//
//  OnboardingFriendsViewController.swift
//  HabitHabit
//
//  Created by Ally on 5/5/21.
//

import UIKit
import FirebaseDatabase

class OnboardingFriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    private let databaseUsernameKey: String = UserDefaults.standard.string(forKey: "kUsername") ?? "USERNAME_DATABASE_KEY_ERROR"
    private let database: DatabaseReference = Database.database().reference()
    private var friendUsernames: [String] = []
    private let buddyTableViewCellIdentifier: String = "BuddyTableViewCell"
    private let aboutFriendSegue: String = "AboutFriendSegue"
    private let refreshControl = UIRefreshControl()
    private var friendRequestsSent: [String] = []
    private var friendRequests: [String] = []
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var userUsernameInput: UITextField!
    @IBOutlet weak var addBuddyButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var buddyTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.habit.purple
        self.buddyTableView.layer.backgroundColor = UIColor.habit.purple.cgColor
        self.buddyTableView.dataSource = self
        self.buddyTableView.delegate = self
        self.loadBuddiesFromDatabase()
        self.setupRefreshControl()
        UIDesign.cleanupButton(button: self.addBuddyButton)
        self.addBuddyButton.setTitle("   Add Friend   ", for: .normal)
        self.statusLabel.text = ""
        self.userUsernameInput?.autocorrectionType = .no
        self.messageLabel.text = "Try adding some friends."
        self.messageLabel.textColor = .white
        self.messageLabel.numberOfLines = 0
        self.messageLabel.textAlignment = .center
        self.messageLabel.font = UIFont(name: "Futura", size: 20)
    }
    
    private func setupRefreshControl() -> Void {
        self.refreshControl.addTarget(self, action: #selector(self.updateFriendsList(_:)), for: .valueChanged)
        self.refreshControl.tintColor = .white
        self.refreshControl.attributedTitle = NSAttributedString(string: "Fetching Friends ...")
        self.buddyTableView.refreshControl = self.refreshControl
    }
    
    @objc private func updateFriendsList(_ sender: Any) -> Void {
        self.loadBuddiesFromDatabase()
    }
    
    private func loadBuddiesFromDatabase() -> Void {
        self.database.child(self.databaseUsernameKey).child("Friends").observe(.value) {
            snapshot in
            var tempFriendList: [String] = []
            for case let child as DataSnapshot in snapshot.children {
                guard let value = child.value as? String else { return }
                tempFriendList.append(value)
            }
            self.friendUsernames = tempFriendList
            self.buddyTableView.reloadData()
            self.refreshControl.endRefreshing()
        }
        self.database.child(self.databaseUsernameKey).child("FriendRequestsSent").observe(.value) {
            snapshot in
            var tempFriendRequestSentList: [String] = []
            for case let child as DataSnapshot in snapshot.children {
                guard let value = child.value as? String else { return }
                tempFriendRequestSentList.append(value)
            }
            self.friendRequestsSent = tempFriendRequestSentList
        }
        self.database.child(self.databaseUsernameKey).child("Friend-Requests").observeSingleEvent(of: .value) {
            snapshot in
            var tempFriendRequestList: [String] = []
            for case let child as DataSnapshot in snapshot.children {
                guard let value = child.value as? String else { return }
                tempFriendRequestList.append(value)
            }
            self.friendRequests = tempFriendRequestList
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friendUsernames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = self.buddyTableView.dequeueReusableCell(withIdentifier: self.buddyTableViewCellIdentifier, for: indexPath as IndexPath) as! GenericTableViewCell
        cell.textLabel?.text = self.friendUsernames[indexPath.row]
        UIDesign.setCellProperties(cell: cell)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // this will turn on `masksToBounds` just before showing the cell
        cell.contentView.layer.masksToBounds = true
        let radius = cell.contentView.layer.cornerRadius
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: radius).cgPath
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func attemptToAddBuddy(_ sender: Any) {
        if let username: String = self.userUsernameInput.text {
            if username == "" {
                self.statusLabel.text = "Nice try QA, please enter a username"
                return
            }
        }
        let username: String = self.userUsernameInput.text!
        if self.friendUsernames.contains(username) {
            self.statusLabel.textColor = .systemRed
            self.statusLabel.text = "The user \(username) is already in your friends list"
            return
        } else if self.friendRequestsSent.contains(username) {
            self.statusLabel.textColor = .systemRed
            self.statusLabel.text = "You have already sent a friend request to \(username)"
            return
        } else if self.friendRequests.contains(username) {
            self.statusLabel.textColor = .systemRed
            self.statusLabel.text = "\(username) has already sent you a friend request. Respond to the friend request on the friend request page"
            return
        }
        self.database.child(username).observeSingleEvent(of: .value) {
            snapshot in
            if snapshot.exists() {
                // self.friendUsernames.append(username)
                // self.buddyTableView.reloadData()
                self.statusLabel.textColor = .green
                self.statusLabel.text = "Sent friend request to \(username)."
                self.friendRequestsSent.append(username)
                self.database.child(username).child("Friend-Requests").child(String(Int.random(in: 0..<1_000_000))).setValue(self.databaseUsernameKey)
                self.database.child(self.databaseUsernameKey).child("FriendRequestsSent").child(String(Int.random(in: 0..<1_000_000))).setValue(username)
            } else {
                self.statusLabel.textColor = .red
                self.statusLabel.text = "Failed to find account: \(username). Make sure you entered the correct username."
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: self.aboutFriendSegue, sender: indexPath.row)
        self.buddyTableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.removeFriendFromDatabase(friendName: self.friendUsernames[indexPath.row])
            self.friendUsernames.remove(at: indexPath.row)
            self.buddyTableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    private func removeFriendFromDatabase(friendName: String) -> Void {
        self.database.child(self.databaseUsernameKey).child("Friends").observeSingleEvent(of: .value) {
            snapshot in
            for case let child as DataSnapshot in snapshot.children {
                guard let value = child.value as? String else { return }
                if value == friendName {
                    self.database.child(self.databaseUsernameKey).child("Friends").child(child.key).removeValue()
                }
            }
        }
        self.database.child(friendName).child("Friends").observeSingleEvent(of: .value) {
            snapshot in
            for case let child as DataSnapshot in snapshot.children {
                guard let value = child.value as? String else { return }
                if value == self.databaseUsernameKey {
                    self.database.child(friendName).child("Friends").child(child.key).removeValue()
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.aboutFriendSegue,
           let destination = segue.destination as? AboutFriendViewController {
            let nameSelected: String = self.friendUsernames[sender as! Int]
            destination.username = nameSelected
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
