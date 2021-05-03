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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.habit.purple
        self.database.child(self.databaseUsernameKey).observeSingleEvent(of: .value) {
            snapshot in
            if !snapshot.exists() {
                self.database.child(self.databaseUsernameKey).setValue(["AccountStatus":"AccountCreated"])
            }
        }
        habitTableView.delegate = self
        habitTableView.dataSource = self
        self.tabBarItem.title = "New Home"
        navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "Habits"
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
                let (habitExists, habit): (Bool, Habit?) = UtilityClass.makeHabit(value: value)
                if habitExists {
                    tempHabitList.append(habit!)
                }
            }
            self.habitsList = tempHabitList
            self.habitTableView.reloadData()
        }
    }
    
    @IBAction func onPressPlus(_ sender: Any) {
        let storyboard = UIStoryboard(name:"Main", bundle:nil)
        let habitManagerView = storyboard.instantiateViewController(withIdentifier: "HabitSettingsVCID")
        self.present(habitManagerView, animated:true, completion:nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "habitPressSegue",
           let nextVC = segue.destination as? DetailedHabitViewController {
            let row = sender as! Int
            nextVC.habit = habitsList[row]
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // this will turn on `masksToBounds` just before showing the cell
        cell.contentView.layer.masksToBounds = true
        let radius = cell.contentView.layer.cornerRadius
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: radius).cgPath
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
    
    private func displayMessage(message: String) -> Void {
        let controller = UIAlertController(
            title: "Unable to add picture",
            message: message,
            preferredStyle: .alert)
        let action = UIAlertAction(
            title: "OK",
            style: .default,
            handler: nil)
        controller.addAction(action)
        present(controller, animated: true, completion: nil)
    }
    
    func takePictureAndUpdateHabit(habit: Habit) {
        let source: UIImagePickerController.SourceType? = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : (UIImagePickerController.isSourceTypeAvailable(.photoLibrary) ? .photoLibrary : nil)
        if source == nil {
            self.displayMessage(message: "Unable to access the camera or the photo libaray.")
        }
        let imagePicker: UIImagePickerController = UIImagePickerController()
        let dates: [Date] = habit.dates
        let canAddPicture: Bool = dates.count == 0 || !Calendar.current.isDateInToday(dates[dates.count - 1])
        if canAddPicture {
            self.habitForImage = habit
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source!
            self.present(imagePicker, animated: true)
        } else {
            self.displayMessage(message: "You have already made an update for the day for the habit \(habit.habit). You can check back in tomorrow")
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
        let todayDate: Date = UtilityClass.getTimeWithCorrectTimeZone()
        let df = DateFormatter()
        df.dateFormat = "LLLL dd, yyyy"
        let imageText: String = df.string(from: todayDate)
        let imageToAdd: UIImage = self.textToImage(drawText: imageText, inImage: image, atPoint: CGPoint(x: 100, y: 100))
        let insertionElement: ImageDatePair = ImageDatePair(image: imageToAdd, date: todayDate)
        UtilityClass.habitNameUpdateDict[self.habitForImage!.habit]!.insert(insertionElement, at: UtilityClass.habitNameUpdateDict[self.habitForImage!.habit]!.insertionIndexOf(insertionElement, isOrderedBefore: { $0.compare($1) }))
        guard let imageData = imageToAdd.jpegData(compressionQuality: UtilityClass.compressionRate) else { return }
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
                        let (habitExists, habitFromDatabase): (Bool, Habit?) = UtilityClass.makeHabit(value: value)
                        if habitExists && self.habitForImage!.equals(habit: habitFromDatabase!) {
                            var currentURLS = habitFromDatabase!.imageUrls
                            currentURLS.append(urlString)
                            self.database.child(self.databaseUsernameKey).child("Habit").child(child.key).child("imageUrls").setValue(currentURLS.joined(separator: ","))
                            var currentUncheckedURLS = habitFromDatabase!.uncheckedImageUrls
                            currentUncheckedURLS.append(urlString)
                            self.database.child(self.databaseUsernameKey).child("Habit").child(child.key).child("uncheckedImageUrls").setValue(currentUncheckedURLS.joined(separator: ","))
                            var currentDates = habitFromDatabase!.dates
                            currentDates.append(todayDate)
                            self.database.child(self.databaseUsernameKey).child("Habit").child(child.key).child("dates").setValue(Habit.convertDateListToStringList(dates: currentDates).joined(separator: ","))
                            var uncheckedDates = habitFromDatabase!.uncheckedDates
                            uncheckedDates.append(todayDate)
                            self.database.child(self.databaseUsernameKey).child("Habit").child(child.key).child("uncheckedDates").setValue(Habit.convertDateListToStringList(dates: currentDates).joined(separator: ","))
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let cell = tableView.cellForRow(at: indexPath as IndexPath)
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        performSegue(withIdentifier: "habitPressSegue", sender: indexPath.row)
    }
    
}
