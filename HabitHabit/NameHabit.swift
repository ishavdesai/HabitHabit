//
//  NameHabit.swift
//  HabitHabit
//
//  Created by Ishav Desai on 4/15/21.
//

import Foundation
import UIKit

class NameHabit {
    let username: String
    let habitName: String
    var imageUrl: String
    var image: UIImage?
    let date: Date
    let habit: Habit
    
    public var description: String { return "Name: \(self.username)\n\thabitName: \(self.habitName)\n\tdate: \(self.date)"}
    
    convenience init(username: String, habitName: String, imageUrl: String, date: Date, habit: Habit) {
        self.init(username: username, habitName: habitName, imageUrl: imageUrl, date: date, habit: habit, image: nil)
    }
    
    init(username: String, habitName: String, imageUrl: String, date: Date, habit: Habit, image: UIImage?) {
        self.username = username
        self.habitName = habitName
        self.imageUrl = imageUrl
        self.date = date
        self.habit = habit
        self.image = image
    }
    
    func compare(_ other: NameHabit) -> Bool {
        return self.date < other.date
    }
    
    func getImage() -> UIImage {
        if self.image != nil {
            return self.image!
        }
        var result: UIImage!
        let sem = DispatchSemaphore.init(value: 0)
        let task = URLSession.shared.dataTask(with: URL(string: imageUrl)!, completionHandler: {
            data, _, error in
            guard let data = data, error == nil else { return }
            result = UIImage(data: data) ?? UIImage(named: "DefaultPeerHabit")
            self.image = result
            sem.signal()
        })
        task.resume()
        sem.wait()
        return result
    }
    
}
