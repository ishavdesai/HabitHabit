//
//  HabitBuddiesManagerViewController.swift
//  HabitHabit
//
//  Created by Ishav Desai on 4/11/21.
//

import UIKit
import FirebaseDatabase

class HabitBuddiesManagerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let databaseUsernameKey: String = UserDefaults.standard.string(forKey: "kUsername") ?? "USERNAME_DATABASE_KEY_ERROR"
    private let database: DatabaseReference = Database.database().reference()
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var buddyTableView: UITableView!
    private var friendUsernames: [String] = []
    private let buddyTableViewCellIdentifier: String = "BuddyTableViewCell"
    @IBOutlet weak var userUsernameInput: UITextField!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var addBuddyButton: UIButton!
    private let aboutFriendSegue: String = "AboutFriendSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 119/255, green: 33/255, blue: 111/255, alpha: 1)
        self.setupPicture()
        self.buddyTableView.dataSource = self
        self.buddyTableView.delegate = self
        self.loadBuddiesFromDatabase()
        UIDesign.cleanupButton(button: self.addBuddyButton)
        self.statusLabel.text = ""
        self.usernameLabel.text = "Your username is: \(self.databaseUsernameKey)"
        self.userUsernameInput?.autocorrectionType = .no
    }
    
    private func modifyImageSettings() -> Void {
        self.profilePicture.contentMode = .scaleAspectFill
        self.profilePicture.clipsToBounds = true
        self.profilePicture.layer.masksToBounds = true
        self.profilePicture.layer.cornerRadius = 150.0/2.0
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
        }
    }
    
    private func setupPicture() -> Void {
        self.database.child(self.databaseUsernameKey).child("ProfilePictureURL").observeSingleEvent(of: .value) {
            snapshot in
            guard let urlString = snapshot.value as? String else {
                let image: UIImage = UIImage(named: "DefaultProfile")!
                self.profilePicture.image = image
                self.modifyImageSettings()
                return
            }
            guard let url = URL(string: urlString) else { return }
            let task = URLSession.shared.dataTask(with: url, completionHandler: {
                data, _, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async {
                    let image = UIImage(data: data)
                    self.profilePicture.image = image
                    self.modifyImageSettings()
                }
            })
            task.resume()
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
            self.statusLabel.textColor = .red
            self.statusLabel.text = "The user \(username) is already in your friends list"
            return
        }
        self.database.child(username).observeSingleEvent(of: .value) {
            snapshot in
            if snapshot.exists() {
                self.friendUsernames.append(username)
                self.buddyTableView.reloadData()
                self.statusLabel.textColor = .green
                self.statusLabel.text = "Added connection with \(username)."
                self.database.child(self.databaseUsernameKey).child("Friends").child(String(Int.random(in: 0..<1_000_000))).setValue(username)
            } else {
                self.statusLabel.textColor = .red
                self.statusLabel.text = "Failed to add connection with \(username). Make sure you entered the correct username."
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.buddyTableView.deselectRow(at: indexPath as IndexPath, animated: true)
        self.performSegue(withIdentifier: self.aboutFriendSegue, sender: indexPath.row)
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
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.aboutFriendSegue,
           let destination = segue.destination as? AboutFriendViewController {
            let nameSelected: String = self.friendUsernames[sender as! Int]
            destination.username = nameSelected
        }
    }
    
}
