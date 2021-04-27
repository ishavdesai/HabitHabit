//
//  FirebaseCommunicator.swift
//  HabitHabit
//
//  Created by Ishav Desai on 4/22/21.
//

import UIKit
import FirebaseDatabase

class UtilityClass {
    
    static let databaseUsernameKey: String = UserDefaults.standard.string(forKey: "kUsername") ?? "USERNAME_DATABASE_KEY_ERROR"
    static let database: DatabaseReference = Database.database().reference()
    static var profilePicture: UIImage = UIImage(named: "DefaultProfile")!
    
    static func saveProfileImage() -> Void {
        self.database.child(self.databaseUsernameKey).child("ProfilePictureURL").observeSingleEvent(of: .value) {
            snapshot in
            guard let urlString = snapshot.value as? String else { return }
            guard let url = URL(string: urlString) else { return }
            let task = URLSession.shared.dataTask(with: url, completionHandler: {
                data, _, error in
                guard let data = data, error == nil else { return }
                let image: UIImage? = UIImage(data: data)
                self.profilePicture = image ?? self.profilePicture
            })
            task.resume()
        }
    }
    
    static func makeHabit(value: [String: String]) -> (Bool, Habit?) {
        let habit: String = value["habit"] ?? "NO_HABIT_EXISTS"
        let timeToRemind: String = value["timeToRemind"] ?? "NO_TIME_TO_REMIND"
        let streak: Int = Int(value["streak"] ?? "") ?? -1
        let dateString: String = value["dates"] ?? ""
        let dates: [Date] = (dateString.count == 0) ? [] : Habit.convertStringListToDateList(strList: dateString.components(separatedBy: ","))
        let rejectedDates: [String] = (value["rejectedDates"] ?? "").components(separatedBy: ",")
        let uncheckedDateString: String = value["uncheckedDates"] ?? ""
        let uncheckedDates: [Date] = (uncheckedDateString.count == 0) ? [] : Habit.convertStringListToDateList(strList: uncheckedDateString.components(separatedBy: ","))
        let imageUrlsString: String = value["imageUrls"] ?? ""
        let imageUrls: [String] = (imageUrlsString == "") ? [] : imageUrlsString.components(separatedBy: ",")
        let uncheckedImageUrlsString: String = value["uncheckedImageUrls"] ?? ""
        let uncheckedImageUrls: [String] = (uncheckedImageUrlsString == "") ? [] : uncheckedImageUrlsString.components(separatedBy: ",")
        let habitExists: Bool = habit != "NO_HABIT_EXISTS" && streak != -1 && timeToRemind != "NO_TIME_TO_REMIND"
        let habitResult: Habit? = habitExists ? Habit(habit: habit, streak: streak, dates: dates, timeToRemind: timeToRemind, imageUrls: imageUrls, uncheckedImageUrls: uncheckedImageUrls, uncheckedDates: uncheckedDates, rejectedDates: rejectedDates) : nil
        return (habitExists, habitResult)
    }
}
