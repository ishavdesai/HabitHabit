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
        self.view.backgroundColor = UIColor(red: 119/255, green: 33/255, blue: 111/255, alpha: 1)
        let df = DateFormatter()
        df.dateFormat = "LLLL dd, yyyy"
        self.userNameLabel.text = self.friendHabit.username
        self.userNameLabel.textColor = .white
        self.habitNameLabel.text = "Does this depict '\(self.friendHabit.habitName)'?"
        self.habitNameLabel.textColor = .white
        self.habitImageView.image = self.friendHabit.getImage()
        self.dateLabel.text = df.string(from: self.friendHabit.date)
        self.dateLabel.textColor = .white
    }
    
    private func removeHabitFromDatabase() {
        self.database.child(self.friendHabit.username).child("Habit").observeSingleEvent(of: .value) {
            snapshot in
            for case let habitChild as DataSnapshot in snapshot.children {
                guard let habitValue = habitChild.value as? [String: String] else { return }
                let (habitExists, habit): (Bool, Habit?) = HabitMaker.makeHabit(value: habitValue)
                if habitExists && self.friendHabit.habit.equals(habit: habit!) {
                    let indexOfImage: Int = habit!.uncheckedImageUrls.firstIndex(of: self.friendHabit.imageUrl)!
                    habit!.uncheckedDates.remove(at: indexOfImage)
                    habit!.uncheckedImageUrls.remove(at: indexOfImage)
                    self.database.child(self.friendHabit.username).child("Habit").child(habitChild.key).child("uncheckedImageUrls").setValue(habit!.uncheckedImageUrls.joined(separator: ","))
                    self.database.child(self.friendHabit.username).child("Habit").child(habitChild.key).child("uncheckedDates").setValue(self.stringifyDateArray(datesParam: habit!.uncheckedDates).joined(separator: ","))
                }
            }
        }
    }
    
    private func stringifyDateArray(datesParam: [Date]) -> [String] {
        var result: [String] = []
        for date in datesParam {
            result.append(date.description)
        }
        return result
    }
    
    @IBAction func checkPressed(_ sender: Any) {
        // that habit's approved count is incremented and delete the peer's habit from the list
        self.navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: {
            self.deletionDelegate.deleteFriendHabitFromTable(index: self.indexInTable)
            self.removeHabitFromDatabase()
        })
    }
    
    @IBAction func denyPressed(_ sender: Any) {
        // that habit's denied count is incremented and delete the peer's habit from the list
        self.navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: {
            self.deletionDelegate.deleteFriendHabitFromTable(index: self.indexInTable)
            self.removeHabitFromDatabase()
        })
    }
    
}
