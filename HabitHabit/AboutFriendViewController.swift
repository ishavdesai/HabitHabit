//
//  AboutFriendViewController.swift
//  HabitHabit
//
//  Created by Ishav Desai on 4/11/21.
//

import UIKit
import FirebaseDatabase

class AboutFriendViewController: UIViewController {
    var username: String = ""
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userHabitsLabel: UILabel!
    private let database: DatabaseReference = Database.database().reference()
    private var habitNamesList: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 119/255, green: 33/255, blue: 111/255, alpha: 1)
        self.usernameLabel.text = "user: \(self.username)"
        self.setupPicture()
        self.readHabitsFromDatabase()
    }
    
    private func modifyImageSettings() -> Void {
        self.profilePicture.contentMode = .scaleAspectFill
        self.profilePicture.clipsToBounds = true
        self.profilePicture.layer.masksToBounds = true
        self.profilePicture.layer.cornerRadius = 150.0/2.0
    }
    
    private func readHabitsFromDatabase() -> Void {
        self.database.child(self.username).child("Habit").observeSingleEvent(of: .value) {
            snapshot in
            for case let child as DataSnapshot in snapshot.children {
                guard let value = child.value as? [String: String] else { return }
                self.habitNamesList.append(value["habit"] ?? "NO_HABIT_EXISTS")
            }
            self.userHabitsLabel.text = "habits: \(self.convertArrToString())"
        }
    }
    
    private func convertArrToString() -> String {
        var result = ""
        for index in 0..<self.habitNamesList.count - 1 {
            result += "\(self.habitNamesList[index]), "
        }
        result += "\(self.habitNamesList[self.habitNamesList.count - 1])"
        return result
    }
    
    private func setupPicture() -> Void {
        self.database.child(self.username).child("ProfilePictureURL").observeSingleEvent(of: .value) {
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
}
