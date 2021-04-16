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
        self.habitNameLabel.text = self.friendHabit.habitName
        self.habitImageView.image = self.friendHabit.getImage()
        self.dateLabel.text = df.string(from: self.friendHabit.date)
    }
    
    private func removeHabitFromDatabase() {
        self.database.child(self.friendHabit.username).child("Habit").observeSingleEvent(of: .value) {
            snapshot in
            for case let habitChild as DataSnapshot in snapshot.children {
                guard let habitValue = habitChild.value as? [String: String] else { return }
                let (habitExists, habit): (Bool, Habit?) = self.makeHabit(value: habitValue)
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
