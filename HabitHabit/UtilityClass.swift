//
//  FirebaseCommunicator.swift
//  HabitHabit
//
//  Created by Ishav Desai on 4/22/21.
//

import UIKit
import FirebaseDatabase

class UtilityClass {
    
    static let database: DatabaseReference = Database.database().reference()
    static var profilePicture: UIImage = UIImage(named: "DefaultProfile")!
    static var habitNameUpdateDict: [String: [ImageDatePair]] = [:]
    static var accountIsPrivate: Bool = false
    static let compressionRate: CGFloat = 0.0
    static var firstTimeSeeingPeerScreen: Bool = true
    static var initialFriendHabits: [NameHabit] = []
    
    static func loadDataForThePeerScreen(username: String) -> Void {
        self.initialFriendHabits.removeAll()
        self.database.child(username).child("Friends").observeSingleEvent(of: .value) {
            snapshotFriend in
            for case let childFriend as DataSnapshot in snapshotFriend.children {
                guard let friend = childFriend.value as? String else { return }
                self.database.child(friend).child("Private").getData {
                    (error, snapshot) in
                    var isPrivate = false
                    if let error = error {
                        print("Error Getting private status: \(error)")
                    } else if snapshot.exists() {
                        isPrivate = snapshot.value as? Bool ?? false
                    }
                    if !isPrivate {
                        self.database.child(friend).child("Habit").observeSingleEvent(of: .value) {
                            snapshotHabit in
                            for case let childHabit as DataSnapshot in snapshotHabit.children {
                                guard let habitValue = childHabit.value as? [String: String] else { return }
                                let (habitExists, habit): (Bool, Habit?) = self.makeHabit(value: habitValue)
                                if habitExists {
                                    for index in 0..<habit!.uncheckedImageUrls.count {
                                        let uncheckedImageUrl: String = habit!.uncheckedImageUrls[index]
                                        let task = URLSession.shared.dataTask(with: URL(string: uncheckedImageUrl)!, completionHandler: {
                                            data, _, error in
                                            guard let data = data, error == nil else { return }
                                            let result: UIImage = UIImage(data: data) ?? UIImage(named: "DefaultPeerHabit")!
                                            let insertionElement: NameHabit = NameHabit(username: friend, habitName: habit!.habit, imageUrl: uncheckedImageUrl, date: habit!.uncheckedDates[index], habit: habit!, image: result)
                                            self.initialFriendHabits.insert(insertionElement, at: self.initialFriendHabits.insertionIndexOf(insertionElement, isOrderedBefore: { $0.compare($1) }))
                                            print("Peer habit added for \(friend) and habit: \(habit!.habit)")
                                        })
                                        task.resume()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    static func saveProfileImage(username: String) -> Void {
        self.database.child(username).child("ProfilePictureURL").observeSingleEvent(of: .value) {
            snapshot in
            if snapshot.exists() {
                guard let urlString = snapshot.value as? String else { return }
                guard let url = URL(string: urlString) else { return }
                let task = URLSession.shared.dataTask(with: url, completionHandler: {
                    data, _, error in
                    guard let data = data, error == nil else { return }
                    let image: UIImage? = UIImage(data: data)
                    self.profilePicture = image ?? UIImage(named: "DefaultProfile")!
                    print("Profile Picture loaded in: \(username)")
                })
                task.resume()
            } else {
                self.profilePicture = UIImage(named: "DefaultProfile")!
                print("Profile picture not there, stick to default")
            }
        }
    }
    
    static func getPrivacyStatus(username: String) -> Void {
        self.database.child(username).child("Private").observeSingleEvent(of: .value) {
            snapshot in
            if snapshot.exists() {
                self.accountIsPrivate = snapshot.value as? Bool ?? false
            }
        }
    }
    
    static func getAllImagesOnly(imageDateList: [ImageDatePair]) -> [UIImage] {
        var result: [UIImage] = []
        for imageDate in imageDateList {
            result.append(imageDate.image)
        }
        return result
    }
    
    static func getTimeWithCorrectTimeZone() -> Date {
        return Date()
    }
    
    static func saveHabitUpdateImages(username: String) -> Void {
        self.database.child(username).child("Habit").observeSingleEvent(of: .value) {
            snapshot in
            var habitList: [Habit] = []
            for case let child as DataSnapshot in snapshot.children {
                guard let value = child.value as? [String: String] else { return }
                let (habitExists, habit): (Bool, Habit?) = self.makeHabit(value: value)
                if habitExists {
                    habitList.append(habit!)
                }
            }
            for habit in habitList {
                let imageUrls = habit.imageUrls
                self.habitNameUpdateDict[habit.habit] = []
                for index in 0..<imageUrls.count {
                    print("Date: \(habit.dates[index])")
                    print("Image URL: \(imageUrls[index])")
                    guard let url = URL(string: imageUrls[index]) else { return }
                    let task = URLSession.shared.dataTask(with: url, completionHandler: {
                        data, _, error in
                        guard let data = data, error == nil else { return }
                        let insertionElement: ImageDatePair = ImageDatePair(image: UIImage(data: data) ?? UIImage(named: "DefaultPeerHabit")!, date: habit.dates[index])
                        self.habitNameUpdateDict[habit.habit]!.insert(insertionElement, at: self.habitNameUpdateDict[habit.habit]!.insertionIndexOf(insertionElement, isOrderedBefore: { $0.compare($1) }))
                        print("IMAGE ADDED FOR HABIT: \(habit.habit)")
                    })
                    task.resume()
                }
            }
        }
    }
    
    static func dateListSameAsDate(dateList: [Date], date: Date) -> Bool {
        for dateInList in dateList {
            if Calendar.current.isDate(dateInList, inSameDayAs: date) {
                return true
            }
        }
        return false
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

extension Array {
    func insertionIndexOf(_ elem: Element, isOrderedBefore: (Element, Element) -> Bool) -> Int {
            var lo = 0
            var hi = self.count - 1
            while lo <= hi {
                let mid = (lo + hi)/2
                if isOrderedBefore(self[mid], elem) {
                    lo = mid + 1
                } else if isOrderedBefore(elem, self[mid]) {
                    hi = mid - 1
                } else {
                    return mid // found at position mid
                }
            }
            return lo // not found, would be inserted at position lo
        }
}
