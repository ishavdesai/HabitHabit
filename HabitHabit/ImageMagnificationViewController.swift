//
//  ImageMagnificationViewController.swift
//  HabitHabit
//
//  Created by Dime Iwata on 4/9/21.
//

import UIKit
import FirebaseDatabase

class ImageMagnificationViewController: UIViewController {
    
    var friendHabit: NameHabit!
    var indexInTable: Int!
    var deletionDelegate: DeleteFriendHabitFromTableDelegate!
    private let database: DatabaseReference = Database.database().reference()
    
    @IBOutlet weak var habitImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var habitNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Habit Approval"
        self.view.backgroundColor = UIColor.habit.purple
        self.setUpLabels()
    }
    
    private func setUpLabels() {
        self.userNameLabel.text = self.friendHabit.username
        self.userNameLabel.textColor = .white
        self.habitNameLabel.text = "Does this depict '\(self.friendHabit.habitName)'?"
        self.habitNameLabel.textColor = .white
        self.habitImageView.image = self.friendHabit.getImage()
        let df = DateFormatter()
        df.dateFormat = "LLLL dd, yyyy"
        self.dateLabel.text = df.string(from: self.friendHabit.date)
        self.dateLabel.textColor = .white
    }
    
    private func removeHabitFromDatabase(checkPressed: Bool) {
        self.database.child(self.friendHabit.username).child("Habit").getData {
            (error, snapshot) in
            if let error = error {
                print("ERROR GETTING DATA: \(error)")
            } else if snapshot.exists() {
                for case let habitChild as DataSnapshot in snapshot.children {
                    guard let habitValue = habitChild.value as? [String: String] else { return }
                    let (habitExists, habit): (Bool, Habit?) = UtilityClass.makeHabit(value: habitValue)
                    if habitExists && self.friendHabit.habit.equals(habit: habit!) {
                        let indexOfImage: Int = habit!.uncheckedImageUrls.firstIndex(of: self.friendHabit.imageUrl)!
                        if !checkPressed {
                            let date = habit!.uncheckedDates[indexOfImage]
                            let format = DateFormatter()
                            format.dateFormat = "yyyy-MM-dd"
                            let dateString = format.string(from: date)
                            habit!.rejectedDates.append(dateString)
                        }
                        habit!.uncheckedDates.remove(at: indexOfImage)
                        habit!.uncheckedImageUrls.remove(at: indexOfImage)
                        self.friendHabit.habit.uncheckedDates.remove(at: indexOfImage)
                        self.friendHabit.habit.uncheckedImageUrls.remove(at: indexOfImage)
                        self.database.child(self.friendHabit.username).child("Habit").child(habitChild.key).child("uncheckedImageUrls").setValue(habit!.uncheckedImageUrls.joined(separator: ","))
                        self.database.child(self.friendHabit.username).child("Habit").child(habitChild.key).child("uncheckedDates").setValue(Habit.convertDateListToStringList(dates: habit!.uncheckedDates).joined(separator: ","))
                        self.database.child(self.friendHabit.username).child("Habit").child(habitChild.key).child("rejectedDates").setValue(habit!.rejectedDates.joined(separator: ","))
                        break
                    }
                }
            } else {
                print("No data available")
            }
        }
    }
    
    @IBAction func checkPressed(_ sender: Any) {
        // that habit's approved count is incremented and delete the peer's habit from the list
        self.navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: {
            self.deletionDelegate.deleteFriendHabitFromTable(index: self.indexInTable)
            self.removeHabitFromDatabase(checkPressed: true)
        })
    }
    
    @IBAction func denyPressed(_ sender: Any) {
        // that habit's denied count is incremented and delete the peer's habit from the list
        self.navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: {
            self.deletionDelegate.deleteFriendHabitFromTable(index: self.indexInTable)
            self.removeHabitFromDatabase(checkPressed: false)
        })
    }
    
}
