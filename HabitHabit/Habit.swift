//
//  Habit.swift
//  HabitHabit
//
//  Created by Ishav Desai on 3/29/21.
//

import Foundation

class Habit {
    let habit: String
    var streak: Int
    var dates: [Date]
    
    init(habit: String) {
        self.habit = habit
        self.streak = 0
        self.dates = []
    }
    
    init(habit: String, streak: Int) {
        self.habit = habit
        self.streak = streak
        self.dates = []
    }
    
    init(habit: String, streak: Int, dates: [Date]) {
        self.habit = habit
        self.streak = streak
        self.dates = dates
    }
    
    func toString() -> String {
        return "Habit: \(self.habit)\nStreak: \(self.streak)\nDates:\(self.stringifyDateArray())"
    }
    
    func stringifyDateArray() -> [String] {
        var result: [String] = []
        for date in self.dates {
            result.append(date.description)
        }
        return result
    }
    
    func convertToJSON() -> [String: String] {
        return [
            "habit": self.habit,
            "streak": String(self.streak),
            "dates": self.stringifyDateArray().joined(separator: ",")
        ]
    }
    
    
    static func convertStringListToDateList(strList: [String]) -> [Date] {
        print("Length: \(strList.count)")
        for date in strList {
            print("Date: \(date)")
        }
        var result: [Date] = []
        let dateFormatter = ISO8601DateFormatter()
        for date in strList {
            result.append(dateFormatter.date(from: date)!)
        }
        return result
    }
    
}
