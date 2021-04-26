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
    let date: Date
    let habit: Habit
    
    public var description: String { return "Name: \(self.username)\n\thabitName: \(self.habitName)\n\tdate: \(self.date)"}
    
    init(username: String, habitName: String, imageUrl: String, date: Date, habit: Habit) {
        self.username = username
        self.habitName = habitName
        self.date = date
        self.imageUrl = imageUrl
        self.habit = habit
    }
    
    func getImage() -> UIImage {
        var result: UIImage!
        let sem = DispatchSemaphore.init(value: 0)
        let task = URLSession.shared.dataTask(with: URL(string: imageUrl)!, completionHandler: {
            data, _, error in
            guard let data = data, error == nil else { return }
            result = UIImage(data: data) ?? UIImage(named: "DefaultPeerHabit")
            sem.signal()
        })
        task.resume()
        sem.wait()
        return result
    }
    
}
