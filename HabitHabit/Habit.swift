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
    var imageUrls: [String]
    var uncheckedImageUrls: [String]
    var uncheckedDates: [Date]
    
    init() {
        self.habit = ""
        self.timeToRemind = ""
        self.streak = 0
        self.dates = []
        self.imageUrls = []
        self.uncheckedImageUrls = []
        self.uncheckedDates = []
    }
    
    init(habit: String) {
        self.habit = habit
        self.timeToRemind = ""
        self.streak = 0
        self.dates = []
        self.imageUrls = []
        self.uncheckedImageUrls = []
        self.uncheckedDates = []
    }
    
    init(habit: String, timeToRemind: String) {
        self.habit = habit
        self.timeToRemind = timeToRemind
        self.streak = 0
        self.dates = []
        self.imageUrls = []
        self.uncheckedImageUrls = []
        self.uncheckedDates = []
    }
    
    init(habit: String, streak: Int) {
        self.habit = habit
        self.timeToRemind = ""
        self.streak = streak
        self.dates = []
        self.imageUrls = []
        self.uncheckedImageUrls = []
        self.uncheckedDates = []
    }
    
    init(habit: String, streak: Int, dates: [Date]) {
        self.habit = habit
        self.timeToRemind = ""
        self.streak = streak
        self.dates = dates
        self.imageUrls = []
        self.uncheckedImageUrls = []
        self.uncheckedDates = []
    }
    
    init(habit: String, streak: Int, dates: [Date], timeToRemind: String) {
        self.habit = habit
        self.streak = streak
        self.dates = dates
        self.timeToRemind = timeToRemind
        self.imageUrls = []
        self.uncheckedImageUrls = []
        self.uncheckedDates = []
    }
    
    init(habit: String, streak: Int, dates: [Date], timeToRemind: String, imageUrls: [String]) {
        self.habit = habit
        self.streak = streak
        self.dates = dates
        self.timeToRemind = timeToRemind
        self.imageUrls = imageUrls
        self.uncheckedImageUrls = []
        self.uncheckedDates = []
    }
    
    init(habit: String, streak: Int, dates: [Date], timeToRemind: String, imageUrls: [String], uncheckedImageUrls: [String]) {
        self.habit = habit
        self.streak = streak
        self.timeToRemind = timeToRemind
        self.dates = dates
        self.imageUrls = imageUrls
        self.uncheckedImageUrls = uncheckedImageUrls
        self.uncheckedDates = []
    }
    
    init(habit: String, streak: Int, dates: [Date], timeToRemind: String, imageUrls: [String], uncheckedImageUrls: [String], uncheckedDates: [Date]) {
        self.habit = habit
        self.streak = streak
        self.timeToRemind = timeToRemind
        self.dates = dates
        self.imageUrls = imageUrls
        self.uncheckedImageUrls = uncheckedImageUrls
        self.uncheckedDates = uncheckedDates
    }
    
    func toString() -> String {
        return self.habit
    }
    
    func stringifyDateArray(datesParam: [Date]) -> [String] {
        var result: [String] = []
        for date in datesParam {
            result.append(date.description)
        }
        return result
    }
    
    func convertToJSON() -> [String: String] {
        return [
            "habit": self.habit,
            "streak": String(self.streak),
            "timeToRemind": self.timeToRemind,
            "dates": self.stringifyDateArray(datesParam: self.dates).joined(separator: ","),
            "imageUrls": self.imageUrls.joined(separator: ","),
            "uncheckedImageUrls": self.uncheckedImageUrls.joined(separator: ","),
            "uncheckedDates": self.stringifyDateArray(datesParam: self.uncheckedDates).joined(separator: ",")
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
        } else if self.imageUrls.count != habit.imageUrls.count {
            return false
        } else if self.uncheckedImageUrls.count != habit.uncheckedImageUrls.count {
            return false
        } else if self.uncheckedDates.count != habit.uncheckedDates.count{
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
        var result: [Date] = []
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        for date in strList {
            result.append(dateFormatterGet.date(from: String(date.prefix(19)))!)
        }
        return result
    }
    
}
