//
//  PeerTableViewController.swift
//  HabitHabit-Zach
//
//  Created by Zach on 3/26/21.
//

import UIKit
import FirebaseDatabase

var peerHabitList:[Habit] = []

protocol peerHabitDeleter {
    func deleteFromPeerList(row: Int)
}

class PeerTableViewController: UITableViewController, peerHabitDeleter {

    @IBOutlet var peerTableView: UITableView!
    private let database: DatabaseReference = Database.database().reference()
    private let databaseUsernameKey: String = UserDefaults.standard.string(forKey: "kUsername") ?? "USERNAME_DATABASE_KEY_ERROR"
    
    let peerCell = "PeerCell"
    var friendHabits: [String: [Habit]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        peerTableView.delegate = self
        peerTableView.dataSource = self
        
        peerHabitList.append(Habit(habit: "bob", streak: 4, dates: []))
        self.friendHabits = self.loadFriendHabits()
        print(self.friendHabits)
    }
    
    private func loadFriendHabits() -> [String: [Habit]] {
        var result: [String: [Habit]] = [:]
        var friends: [String] = []
        let sem = DispatchSemaphore.init(value: 0)
        self.database.child(self.databaseUsernameKey).child("Friends").observe(.value) {
            snapshot in
            for case let child as DataSnapshot in snapshot.children {
                guard let value = child.value as? String else { return }
                friends.append(value)
            }
            for friend in friends {
                var friendHabitList: [Habit] = []
                self.database.child(friend).child("Habit").observe(.value) {
                    snapshot in
                    if snapshot.exists() {
                        for case let child as DataSnapshot in snapshot.children {
                            guard let value = child.value as? [String: String] else { return }
                            let (habitExists, habit): (Bool, Habit?) = self.makeHabit(value: value)
                            if habitExists {
                                friendHabitList.append(habit!)
                            }
                        }
                        result[friend] = friendHabitList
                    }
                }
            }
            sem.signal()
        }
        sem.wait()
        return result
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
    
    override func viewWillAppear(_ animated: Bool) {
        self.peerTableView.reloadData()
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
