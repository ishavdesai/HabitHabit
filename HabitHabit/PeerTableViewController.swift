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
        self.view.backgroundColor = UIColor(red: 119/255, green: 33/255, blue: 111/255, alpha: 1)
        self.peerTableView.delegate = self
        self.peerTableView.dataSource = self
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
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: self.imageMagnificationSegue, sender: (self.friendHabits[indexPath.row], indexPath.row))
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
        self.database.child(self.databaseUsernameKey).child("Friends").observeSingleEvent(of: .value) {
            snapshotFriend in
            for case let childFriend as DataSnapshot in snapshotFriend.children {
                guard let friend = childFriend.value as? String else { return }
                self.database.child(friend).child("Habit").observeSingleEvent(of: .value) {
                    snapshotHabit in
                    for case let childHabit as DataSnapshot in snapshotHabit.children {
                        guard let habitValue = childHabit.value as? [String: String] else { return }
                        let (habitExists, habit): (Bool, Habit?) = self.makeHabit(value: habitValue)
                        if habitExists {
                            for index in 0..<habit!.uncheckedImageUrls.count {
                                self.friendHabits.append(NameHabit(username: friend, habitName: habit!.habit, imageUrl: habit!.uncheckedImageUrls[index], date: habit!.uncheckedDates[index], habit: habit!))
                                print("New NameHabit is added")
                                self.peerTableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func makeHabit(value: [String: String]) -> (Bool, Habit?) {
        let habit: String = value["habit"] ?? "NO_HABIT_EXISTS"
        let timeToRemind: String = value["timeToRemind"] ?? "NO_TIME_TO_REMIND"
        let streak: Int = Int(value["streak"] ?? "") ?? -1
        let dateString: String = value["dates"] ?? ""
        let dates: [Date] = (dateString.count == 0) ? [] : Habit.convertStringListToDateList(strList: dateString.components(separatedBy: ","))
        let uncheckedDateString: String = value["uncheckedDates"] ?? ""
        let uncheckedDates: [Date] = (uncheckedDateString.count == 0) ? [] : Habit.convertStringListToDateList(strList: uncheckedDateString.components(separatedBy: ","))
        let imageUrlsString: String = value["imageUrls"] ?? ""
        let imageUrls: [String] = (imageUrlsString == "") ? [] : imageUrlsString.components(separatedBy: ",")
        let uncheckedImageUrlsString: String = value["uncheckedImageUrls"] ?? ""
        let uncheckedImageUrls: [String] = (uncheckedImageUrlsString == "") ? [] : uncheckedImageUrlsString.components(separatedBy: ",")
        let habitExists: Bool = habit != "NO_HABIT_EXISTS" && streak != -1 && timeToRemind != "NO_TIME_TO_REMIND"
        let habitResult: Habit? = habitExists ? Habit(habit: habit, streak: streak, dates: dates, timeToRemind: timeToRemind, imageUrls: imageUrls, uncheckedImageUrls: uncheckedImageUrls, uncheckedDates: uncheckedDates) : nil
        return (habitExists, habitResult)
    }
    
}
