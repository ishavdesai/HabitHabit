//
//  Habit.swift
//  HabitHabit
//
//  Created by Ishav Desai on 3/29/21.
//

import Foundation

class Habit {
    let habit: String
    var timeToRemind: String
    var streak: Int
    var dates: [Date]
    
    init(habit: String) {
        self.habit = habit
        self.timeToRemind = ""
        self.streak = 0
        self.dates = []
    }
    
    init(habit: String, timeToRemind: String) {
        self.habit = habit
        self.timeToRemind = timeToRemind
        self.streak = 0
        self.dates = []
    }
    
    init(habit: String, streak: Int) {
        self.habit = habit
        self.timeToRemind = ""
        self.streak = streak
        self.dates = []
    }
    
    init(habit: String, streak: Int, dates: [Date]) {
        self.habit = habit
        self.timeToRemind = ""
        self.streak = streak
        self.dates = dates
    }
    
    init(habit: String, streak: Int, dates: [Date], timeToRemind: String) {
        self.habit = habit
        self.streak = streak
        self.dates = dates
        self.timeToRemind = timeToRemind
    }
    
    func toString() -> String {
        return self.habit
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
            "timeToRemind": self.timeToRemind,
            "dates": self.stringifyDateArray().joined(separator: ",")
        ]
    }
    
    func equals(habit: Habit) -> Bool {
        if self.habit != habit.habit {
            return false
        } else if self.streak != habit.streak {
            return false
        } else if self.dates.count != habit.dates.count {
            return false
        } else if self.timeToRemind != habit.timeToRemind {
            return false
        } else {
            for (index, _) in self.dates.enumerated() {
                if self.dates[index] != habit.dates[index] {
                    return false
                }
            }
        }
        return true
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
