//
//  AboutFriendViewController.swift
//  HabitHabit
//
//  Created by Ishav Desai on 4/11/21.
//

import UIKit
import FirebaseDatabase

class AboutFriendViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, HabitImageTrackerDelegate {
    
    var username: String = ""
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userHabitsLabel: UILabel!
    @IBOutlet weak var buddyHabitTable: UITableView!
    private let database: DatabaseReference = Database.database().reference()
    private var habitNamesList: [Habit] = []
    
    
    //----------------------------
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return habitNamesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let habit = habitNamesList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "HabitCell") as! HabitTableViewCell
        print(habit.habit)
        cell.setProperties(habit: habit, delegate: self, noCamera: true)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.buddyHabitTable.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.layer.masksToBounds = true
        let radius = cell.contentView.layer.cornerRadius
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: radius).cgPath
    }
    
    func takePictureAndUpdateHabit(habit: Habit) {
        print("NOT SUPPOSED TO HAPPEN")
    }
    //----------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.habit.purple
        self.usernameLabel.text = "user: \(self.username)"
        self.title = self.username
        self.setupPicture()
        self.readHabitsFromDatabase()
        buddyHabitTable.delegate = self
        buddyHabitTable.dataSource = self
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
            var tempHabitList: [Habit] = []
            for case let child as DataSnapshot in snapshot.children {
                guard let value = child.value as? [String: String] else {
                    return
                }
                let (habitExists, habit): (Bool, Habit?) = HabitMaker.makeHabit(value: value)
                if habitExists {
                    tempHabitList.append(habit!)
                }
            }
            self.habitNamesList = tempHabitList
            self.buddyHabitTable.reloadData()
        }
    }
    
    private func convertArrToString() -> String {
        if self.habitNamesList.count == 0 {
            return ""
        }
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
