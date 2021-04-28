//
//  OptionsViewController.swift
//  HabitHabit-Zach
//
//  Created by Zach on 3/26/21.
//

import UIKit
import Firebase
import FirebaseDatabase

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let settingsList: [String] = ["Profile", "Habits", "History", "Friends", "Friend Requests"]
    let segueIdentifiers: [String] = ["ProfileScreenSegueIdentifier", "HabitScreenSegueIdentifier", "HistorySegueIdentifier", "HabitBuddiesSegue", "FriendRequestsSegue"]
    let settingsTableViewCellIdentifier: String = "SettingsTableViewCell"
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var settingsTableView: UITableView!
    @IBOutlet weak var logOutButton: UIBarButtonItem!
    private let databaseUsernameKey: String = UserDefaults.standard.string(forKey: "kUsername") ?? "USERNAME_DATABASE_KEY_ERROR"
    private let database: DatabaseReference = Database.database().reference()
    private let logOutSegue: String = "logOutSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.habit.purple
        self.settingsTableView.delegate = self
        self.settingsTableView.dataSource = self
        self.setupPicture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupPicture()
    }
    
    private func modifyImageSettings() -> Void {
        self.profilePicture.contentMode = .scaleAspectFill
        self.profilePicture.clipsToBounds = true
        self.profilePicture.layer.masksToBounds = true
        self.profilePicture.layer.cornerRadius = 150.0/2.0
    }
    
    private func setupPicture() -> Void {
        self.profilePicture.image = UtilityClass.profilePicture
        self.modifyImageSettings()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.settingsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.settingsTableView.dequeueReusableCell(withIdentifier: self.settingsTableViewCellIdentifier, for: indexPath as IndexPath) as! GenericTableViewCell
        cell.textLabel?.text = self.settingsList[indexPath.row]
        //UIDesign.setCellProperties(cell: cell)
        return cell
    }
    
    /*
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // this will turn on `masksToBounds` just before showing the cell
        cell.contentView.layer.masksToBounds = true
        let radius = cell.contentView.layer.cornerRadius
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: radius).cgPath
    }
    */
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: self.segueIdentifiers[indexPath.row], sender: nil)
        self.settingsTableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func logOutButtonPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: self.logOutSegue, sender: nil)
        } catch _ as NSError {
            let alert = UIAlertController(
                title: "Error signing out",
                message: "Ensure you have an internet connection to sign out",
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(
                                title: "Dismiss",
                                style: .cancel,
                                handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}
