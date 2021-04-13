//
//  HabitSettingsViewController.swift
//  HabitHabit
//
//  Created by Ishav Desai on 3/29/21.
//

import UIKit
import FirebaseDatabase
import UserNotifications

class HabitSettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let databaseUsernameKey: String = UserDefaults.standard.string(forKey: "kUsername") ?? "USERNAME_DATABASE_KEY_ERROR"
    private let database: DatabaseReference = Database.database().reference()
    @IBOutlet weak var habitsTableView: UITableView!
    private var habitsList: [Habit] = []
    private let habitCellIdentifier: String = "HabitTableCell"
    @IBOutlet weak var habitTextField: UITextField!
    @IBOutlet weak var timePicker: UITextField!
    let timePickerView: UIDatePicker = UIDatePicker()
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var addHabitButton: UIButton!
    @IBOutlet weak var currentHabitsLabel: UILabel!
    
    
    func configureConstraints() {
        currentHabitsLabel.topAnchor.constraint(equalTo: habitsTableView.bottomAnchor, constant:10).isActive = true
        habitsTableView.topAnchor.constraint(equalTo: currentHabitsLabel.bottomAnchor, constant:10).isActive = true
        habitTextField.bottomAnchor.constraint(equalTo: timePicker.topAnchor, constant:15).isActive = true
        timePicker.topAnchor.constraint(equalTo: habitTextField.bottomAnchor, constant:10).isActive = true
        addHabitButton.topAnchor.constraint(equalTo:timePicker.bottomAnchor, constant:55).isActive = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 119/255, green: 33/255, blue: 111/255, alpha: 1)
        self.habitsTableView.delegate = self
        self.habitsTableView.dataSource = self
        self.setupTextFields()
        //self.configureConstraints()
        self.setupPicture()
        self.readHabitsFromDatabase()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupPicture()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let storyboard = UIStoryboard(name:"Main", bundle:nil)
        let landingPageView = storyboard.instantiateViewController(withIdentifier: "LandingPageVCID") as? LandingPageViewController
        landingPageView?.refreshView()
    }
    
    private func modifyImageSettings() -> Void {
        self.profilePicture.contentMode = .scaleAspectFill
        self.profilePicture.clipsToBounds = true
        self.profilePicture.layer.masksToBounds = true
        self.profilePicture.layer.cornerRadius = 150.0/2.0
    }
    
    private func setupPicture() -> Void {
        self.database.child(self.databaseUsernameKey).child("ProfilePictureURL").observeSingleEvent(of: .value) {
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
    
    private func setupTextFields() -> Void {
        self.habitTextField.placeholder = "Add a habit"
        self.habitTextField.textAlignment = .center
        self.timePicker.placeholder = "Select time to be reminded at every day"
        self.timePicker.textAlignment = .center
        let toolbar: UIToolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton: UIBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: nil,
            action: #selector(donePressed))
        toolbar.setItems([doneButton], animated: true)
        self.timePicker.inputAccessoryView = toolbar
        self.timePicker.inputView = self.timePickerView
        self.timePickerView.datePickerMode = .time
        self.timePickerView.frame.size = CGSize(width: 0, height: 250)
    }
    
    @objc func donePressed() {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        self.timePicker.text = formatter.string(from: self.timePickerView.date)
        self.view.endEditing(true)
        print(self.timePicker.text!)
    }
    
    private func readHabitsFromDatabase() -> Void {
        self.database.child(self.databaseUsernameKey).child("Habit").observeSingleEvent(of: .value) {
            snapshot in
            for case let child as DataSnapshot in snapshot.children {
                guard let value = child.value as? [String: String] else { return }
                let (habitExists, habit): (Bool, Habit?) = self.makeHabit(value: value)
                if habitExists {
                    self.habitsList.append(habit!)
                    self.habitsTableView.reloadData()
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
        let habitExists: Bool = habit != "NO_HABIT_EXISTS" && streak != -1 && timeToRemind != "NO_TIME_TO_REMIND"
        let habitResult: Habit? = habitExists ? Habit(habit: habit, streak: streak, dates: dates, timeToRemind: timeToRemind) : nil
        return (habitExists, habitResult)
    }
    
    private func showAlert(title: String, message: String) {
        let errorController: UIAlertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        errorController.addAction(UIAlertAction(
                                    title: "OK",
                                    style: .default,
                                    handler: nil))
        present(errorController, animated: true, completion: nil)
    }
    
    private func checkFieldAccuracy(habitString: String?, timeToRemind: String?) -> Bool {
        if habitString == "" {
            self.showAlert(title: "Missing Habit", message: "No Habit has been entered. Please type a habit")
            return false
        } else if timeToRemind == "" {
            self.showAlert(title: "Missing Time", message: "No Time to be reminded has been entered. Please enter a time to remind you to do a habit")
            return false
        }
        return true
    }
    
    private func giveNumericalTime(time: String) -> (Int, Int) {
        var hourString: String = ""
        var minuteString: String = ""
        var timeOfDay: String = ""
        var state: Int = 0
        for element in time {
            if element == ":" {
                state = 1
                continue
            } else if element == " " {
                state = 2
                continue
            }
            if state == 0 {
                hourString += String(element)
            } else if state == 1 {
                minuteString += String(element)
            } else if state == 2 {
                timeOfDay += String(element)
            }
        }
        var hour: Int = Int(hourString) ?? -1
        let minute: Int = Int(minuteString) ?? -1
        if timeOfDay == "PM" {
            hour += 12
        }
        return (hour, minute)
    }
    
    private func addToNotificationQueue(habit: Habit) -> Void {
        let notification: UNMutableNotificationContent = UNMutableNotificationContent()
        notification.title = "Time for your Habit!"
        notification.subtitle = "\(habit.habit)"
        notification.body = "Do your task and commemorate it with a picture"
        notification.sound = .defaultCritical
        let (hour, minute): (Int, Int) = self.giveNumericalTime(time: habit.timeToRemind)
        print("NOTIFICATION TIME: \(hour): \(minute)")
        var dateComponents: DateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        let notificationTrigger: UNNotificationTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "Reminder to do habit\(habit.habit)",
            content: notification,
            trigger: notificationTrigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: {
            (error) in
            if error != nil {
                print("ERROR SCHEDULING NOTIFICATION")
            }
        })
    }
    
    @IBAction func addNewHabit(_ sender: Any) {
        let habitString: String? = self.habitTextField.text
        let timeToRemind: String? = self.timePicker.text
        if self.checkFieldAccuracy(habitString: habitString, timeToRemind: timeToRemind) {
            let newHabit: Habit = Habit(habit: habitString!, timeToRemind: timeToRemind!)
            self.habitsList.append(newHabit)
            self.habitsTableView.reloadData()
            self.addToNotificationQueue(habit: newHabit)
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
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.habitsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = self.habitsTableView.dequeueReusableCell(withIdentifier: self.habitCellIdentifier, for: indexPath as IndexPath)
        cell.textLabel?.text = self.habitsList[indexPath.row].toString()
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let habit: Habit = self.habitsList[indexPath.row]
            self.habitsList.remove(at: indexPath.row)
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["Reminder to do habit\(habit.habit)"])
            self.removeFromDatabase(habit: habit)
            self.habitsTableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    private func removeFromDatabase(habit: Habit) -> Void {
        self.database.child(self.databaseUsernameKey).child("Habit").observeSingleEvent(of: .value) {
            snapshot in
            for case let child as DataSnapshot in snapshot.children {
                guard let value = child.value as? [String: String] else { return }
                let (habitExists, habitFromDatabase): (Bool, Habit?) = self.makeHabit(value: value)
                if habitExists && habit.equals(habit: habitFromDatabase!) {
                    self.database.child(self.databaseUsernameKey).child("Habit").child(child.key).removeValue()
                    return
                }
            }
        }
    }
}
