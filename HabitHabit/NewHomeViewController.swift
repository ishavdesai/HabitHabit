//
//  NewHomeViewController.swift
//  HabitHabit
//
//  Created by Shreyas Amargol on 3/30/21.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

protocol HabitImageTrackerDelegate {
    func takePictureAndUpdateHabit(habit: Habit) -> Void
}

class NewHomeViewController: UIViewController {
    
    @IBOutlet weak var habitTableView: UITableView!
    
    private var habitsList: [Habit] = []
    private var habitForImage: Habit? = nil
    private let storage = Storage.storage().reference()
    private let database: DatabaseReference = Database.database().reference()
    private let databaseUsernameKey: String = UserDefaults.standard.string(forKey: "kUsername") ?? "USERNAME_DATABASE_KEY_ERROR"
    private let username: String = UserDefaults.standard.string(forKey: "kUsername") ?? "USERNAME_KEY_ERROR"
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.database.child(self.databaseUsernameKey).observeSingleEvent(of: .value) {
            snapshot in
            if !snapshot.exists() {
                self.database.child(self.databaseUsernameKey).setValue("")
            }
        }
        habitTableView.delegate = self
        habitTableView.dataSource = self
                
        self.tabBarItem.title = "New Home"
        navigationController?.navigationBar.prefersLargeTitles = true
//        navigationItem.largeTitleDisplayMode = .never
        
        let now = Date()
        let df = DateFormatter()
        df.dateFormat = "LLLL dd, yyyy"
        navigationItem.title = df.string(from: now)
//
//        habitsList.append(Habit(habit: "Wake Up Early", streak: 3, dates: []))
//        habitsList.append(Habit(habit: "Go for a run", streak: 1, dates: []))
        
        self.populateHabits()
    }
    
    private func populateHabits() -> Void {
        self.database.child(self.databaseUsernameKey).child("Habit").observe(.value) {
            snapshot in
            var tempHabitList: [Habit] = []
            for case let child as DataSnapshot in snapshot.children {
                guard let value = child.value as? [String: String] else {
                    return
                }
                let (habitExists, habit): (Bool, Habit?) = self.makeHabit(value: value)
                if habitExists {
                    tempHabitList.append(habit!)
                }
            }
            self.habitsList = tempHabitList
            self.habitTableView.reloadData()
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
    
    @IBAction func onPressPlus(_ sender: Any) {
        let storyboard = UIStoryboard(name:"Main", bundle:nil)
        let habitManagerView = storyboard.instantiateViewController(withIdentifier: "HabitSettingsVCID")
        self.present(habitManagerView, animated:true, completion:nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "habitPressSegue",
           let nextVC = segue.destination as? DetailedHabitViewController {
            let row = sender as! Int
            
            nextVC.habit = habitsList[row]
        }

    }
}

extension NewHomeViewController: UITableViewDataSource, UITableViewDelegate, HabitImageTrackerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return habitsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let habit = habitsList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "HabitCell") as! HabitTableViewCell
        cell.setProperties(habit: habit, delegate: self)
        return cell
    }
    
    func takePictureAndUpdateHabit(habit: Habit) {
        let imagePicker: UIImagePickerController = UIImagePickerController()
        let dates: [Date] = habit.dates
        let canAddPicture: Bool = dates.count == 0 || !Calendar.current.isDateInToday(dates[dates.count - 1])
        if canAddPicture {
            self.habitForImage = habit
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true)
        } else {
            let controller = UIAlertController(
                title: "Unable to add picture",
                message: "You have already made an update for the day for the habit \(habit.habit). You can check back in tomorrow",
                preferredStyle: .alert)
            let action = UIAlertAction(
                title: "OK",
                style: .default,
                handler: nil)
            controller.addAction(action)
            present(controller, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage else { return }
        self.setupAndStoreTakenImage(image: image)
    }
    
    private func setupAndStoreTakenImage(image: UIImage) -> Void {
        let todayDate: Date = Date()
        let df = DateFormatter()
        df.dateFormat = "LLLL dd, yyyy"
        let imageText: String = df.string(from: todayDate)
        let imageToAdd: UIImage = self.textToImage(drawText: imageText, inImage: image, atPoint: CGPoint(x: 100, y: 100))
        guard let imageData = imageToAdd.pngData() else { return }
        let randomNumber: Int = Int.random(in: 0..<1_000_000)
        self.storage.child(self.databaseUsernameKey).child("Habit").child(self.habitForImage!.habit).child(String(randomNumber)).putData(imageData, metadata: nil, completion: {
            _, error in
            guard error == nil else {
                print("Failed to upload"); return
            }
            self.storage.child(self.databaseUsernameKey).child("Habit").child(self.habitForImage!.habit).child(String(randomNumber)).downloadURL(completion: {
                url, error in
                guard let url = url, error == nil else { return }
                let urlString = url.absoluteString
                self.database.child(self.databaseUsernameKey).child("Habit").observeSingleEvent(of: .value) {
                    snapshot in
                    for case let child as DataSnapshot in snapshot.children {
                        guard let value = child.value as? [String: String] else { return }
                        let (habitExists, habitFromDatabase): (Bool, Habit?) = self.makeHabit(value: value)
                        if habitExists && self.habitForImage!.equals(habit: habitFromDatabase!) {
                            var currentURLS = habitFromDatabase!.imageUrls
                            currentURLS.append(urlString)
                            self.database.child(self.databaseUsernameKey).child("Habit").child(child.key).child("imageUrls").setValue(currentURLS.joined(separator: ","))
                            var currentUncheckedURLS = habitFromDatabase!.uncheckedImageUrls
                            currentUncheckedURLS.append(urlString)
                            self.database.child(self.databaseUsernameKey).child("Habit").child(child.key).child("uncheckedImageUrls").setValue(currentUncheckedURLS.joined(separator: ","))
                            var currentDates = habitFromDatabase!.dates
                            currentDates.append(todayDate)
                            self.database.child(self.databaseUsernameKey).child("Habit").child(child.key).child("dates").setValue(self.stringifyDateArray(dates: currentDates).joined(separator: ","))
                            var uncheckedDates = habitFromDatabase!.uncheckedDates
                            uncheckedDates.append(todayDate)
                            self.database.child(self.databaseUsernameKey).child("Habit").child(child.key).child("uncheckedDates").setValue(self.stringifyDateArray(dates: uncheckedDates).joined(separator: ","))
                            if currentDates.count == 1 {
                                self.database.child(self.databaseUsernameKey).child("Habit").child(child.key).child("streak").setValue(String(1))
                            } else if currentDates.count >= 2 {
                                let secondRecentDate = currentDates[currentDates.count - 2]
                                if Calendar.current.isDateInYesterday(secondRecentDate) {
                                    self.database.child(self.databaseUsernameKey).child("Habit").child(child.key).child("streak").setValue(String(habitFromDatabase!.streak + 1))
                                } else {
                                    self.database.child(self.databaseUsernameKey).child("Habit").child(child.key).child("streak").setValue(String(0))
                                }
                            }
                        }
                    }
                }
            })
        })
    }
    
    // from https://stackoverflow.com/questions/28906914/how-do-i-add-text-to-an-image-in-ios-swift
    private func textToImage(drawText text: String, inImage image: UIImage, atPoint point: CGPoint) -> UIImage {
        let textColor = UIColor.white
        let textFont = UIFont(name: "Helvetica Bold", size: 24)!

        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)

        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
            ] as [NSAttributedString.Key : Any]
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))

        let rect = CGRect(origin: point, size: image.size)
        text.draw(in: rect, withAttributes: textFontAttributes)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
    
    private func stringifyDateArray(dates: [Date]) -> [String] {
        var result: [String] = []
        for date in dates {
            result.append(date.description)
        }
        return result
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let cell = tableView.cellForRow(at: indexPath as IndexPath)
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        performSegue(withIdentifier: "habitPressSegue", sender: indexPath.row)
    }

}
