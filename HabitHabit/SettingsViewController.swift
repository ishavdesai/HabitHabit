//
//  OptionsViewController.swift
//  HabitHabit-Zach
//
//  Created by Zach on 3/26/21.
//

import UIKit
import FirebaseDatabase

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let settingsList: [String] = ["Profile", "Habits"]
    let segueIdentifiers: [String] = ["ProfileScreenSegueIdentifier", "HabitScreenSegueIdentifier"]
    let settingsTableViewCellIdentifier: String = "SettingsTableViewCell"
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var settingsTableView: UITableView!
    private let databaseUsernameKey: String = UserDefaults.standard.string(forKey: "kUsernameDatabaseKey") ?? "USERNAME_DATABASE_KEY_ERROR"
    private let database: DatabaseReference = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.settingsTableView.delegate = self
        self.settingsTableView.dataSource = self
        self.setupPicture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupPicture()
    }
    
    private func setupPicture() -> Void {
        self.database.child(self.databaseUsernameKey).child("ProfilePictureURL").observeSingleEvent(of: .value) {
            snapshot in
            guard let urlString = snapshot.value as? String else {
                let image: UIImage = UIImage(named: "DefaultProfile")!
                self.profilePicture.image = image
                self.profilePicture.layer.masksToBounds = true
                self.profilePicture.layer.cornerRadius = self.profilePicture.bounds.width / 2
                return
            }
            guard let url = URL(string: urlString) else { return }
            let task = URLSession.shared.dataTask(with: url, completionHandler: {
                data, _, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async {
                    let image = UIImage(data: data)
                    self.profilePicture.image = image
                    self.profilePicture.layer.masksToBounds = true
                    self.profilePicture.layer.cornerRadius = self.profilePicture.bounds.width / 2
                }
            })
            task.resume()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.settingsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.settingsTableView.dequeueReusableCell(withIdentifier: self.settingsTableViewCellIdentifier, for: indexPath as IndexPath)
        cell.textLabel?.text = self.settingsList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: self.segueIdentifiers[indexPath.row], sender: nil)
    }

}
