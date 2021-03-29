//
//  HabitSettingsViewController.swift
//  HabitHabit
//
//  Created by Ishav Desai on 3/29/21.
//

import UIKit
import FirebaseDatabase

class HabitSettingsViewController: UIViewController {
    
    private let databaseUsernameKey: String = UserDefaults.standard.string(forKey: "kUsernameDatabaseKey") ?? "USERNAME_DATABASE_KEY_ERROR"
    private let database: DatabaseReference = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func addNewHabit(_ sender: Any) {
        let habitController: UIAlertController =
            UIAlertController(
                title: "Add a Habit",
                message: "Enter the Habit you would like to make",
                preferredStyle: .alert)
        habitController.addAction(UIAlertAction(
                                    title: "Cancel",
                                    style: .cancel,
                                    handler: nil))
        habitController.addTextField(configurationHandler: {(textField: UITextField!) in textField.placeholder = "Enter habit"})
        habitController.addAction(UIAlertAction(
                                    title: "Make Habit",
                                    style: .default,
                                    handler: {
                                        (paramAction: UIAlertAction!) in
                                        if let enteredHabitsArray = habitController.textFields {
                                            let enteredHabits = enteredHabitsArray as [UITextField]
                                            let enteredHabit: String = enteredHabits[0].text!
                                            let newHabit: Habit = Habit(habit: enteredHabit)
                                            self.database.child(self.databaseUsernameKey).child("HabitCount").observeSingleEvent(of: .value) {
                                                snapshot in
                                                guard let value = snapshot.value as? String else {
                                                    let habitCount: Int = 1
                                                    self.database.child(self.databaseUsernameKey).child("Habit").child("\(habitCount)").setValue(newHabit.convertToJSON())
                                                    self.database.child(self.databaseUsernameKey).child("HabitCount").setValue(String(habitCount + 1))
                                                    return
                                                }
                                                let habitCount: Int = Int(value) ?? 1
                                                self.database.child(self.databaseUsernameKey).child("Habit").child("\(habitCount)").setValue(newHabit.convertToJSON())
                                                self.database.child(self.databaseUsernameKey).child("HabitCount").setValue(String(habitCount + 1))
                                            }
                                        }
                                    }))
        present(habitController, animated: true, completion: nil)
    }
}
