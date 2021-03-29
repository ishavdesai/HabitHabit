//
//  ViewHabitsViewController.swift
//  HabitHabit
//
//  Created by Ishav Desai on 3/29/21.
//

import UIKit
import Foundation
import FirebaseDatabase

class ViewHabitsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var habitsTableView: UITableView!
    private let databaseUsernameKey: String = UserDefaults.standard.string(forKey: "kUsernameDatabaseKey") ?? "USERNAME_DATABASE_KEY_ERROR"
    private let database: DatabaseReference = Database.database().reference()
    private var habitsList: [Habit] = []
    private let habitCellIdentifier: String = "HabitCellIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.habitsTableView.delegate = self
        self.habitsTableView.dataSource = self
        self.readHabitsFromDatabase()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.habitsTableView.reloadData()
    }
    
    private func readHabitsFromDatabase() -> Void {
        self.database.child(self.databaseUsernameKey).child("Habit").observeSingleEvent(of: .value) { snapshot in
            for case let child as DataSnapshot in snapshot.children {
                guard let value = child.value as? [String: String] else {
                    return
                }
                let habit: String = value["habit"] ?? "NO_HABIT_EXISTS"
                let streak: Int = Int(value["streak"] ?? "") ?? -1
                let dateString: String = (value["dates"] ?? "")
                let dates: [Date] = (dateString.count == 0) ? [] : Habit.convertStringListToDateList(strList: dateString.components(separatedBy: ","))
                if habit != "NO_HABIT_EXISTS" && streak != -1 {
                    self.habitsList.append(Habit(habit: habit, streak: streak, dates: dates))
                    self.habitsTableView.reloadData()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.habitsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.habitsTableView.dequeueReusableCell(withIdentifier: self.habitCellIdentifier, for: indexPath as IndexPath)
        cell.textLabel?.text = self.habitsList[indexPath.row].toString()
        return cell
    }

}
