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
    var rejectedDates: [String]
    
    convenience init() {
        self.init(habit: "")
    }
    
    convenience init(habit: String) {
        self.init(habit: habit, streak: 0)
    }
    
    convenience init(habit: String, timeToRemind: String) {
        self.init(habit: habit, streak: 0, dates: [], timeToRemind: timeToRemind)
    }
    
    convenience init(habit: String, streak: Int) {
        self.init(habit: habit, streak: streak, dates: [])
    }
    
    convenience init(habit: String, streak: Int, dates: [Date]) {
        self.init(habit: habit, streak: streak, dates: dates, timeToRemind: "")
    }
    
    convenience init(habit: String, streak: Int, dates: [Date], timeToRemind: String) {
        self.init(habit: habit, streak: streak, dates: dates, timeToRemind: timeToRemind, imageUrls: [])
    }
    
    convenience init(habit: String, streak: Int, dates: [Date], timeToRemind: String, imageUrls: [String]) {
        self.init(habit: habit, streak: streak, dates: dates, timeToRemind: timeToRemind, imageUrls: imageUrls, uncheckedImageUrls: [])
    }
    
    convenience init(habit: String, streak: Int, dates: [Date], timeToRemind: String, imageUrls: [String], uncheckedImageUrls: [String]) {
        self.init(habit: habit, streak: streak, dates: dates, timeToRemind: timeToRemind, imageUrls: imageUrls, uncheckedImageUrls: uncheckedImageUrls, uncheckedDates: [])
    }
    
    convenience init(habit: String, streak: Int, dates: [Date], timeToRemind: String, imageUrls: [String], uncheckedImageUrls: [String], uncheckedDates: [Date]) {
        self.init(habit: habit, streak: streak, dates: dates, timeToRemind: timeToRemind, imageUrls: imageUrls, uncheckedImageUrls: uncheckedImageUrls, uncheckedDates: uncheckedDates, rejectedDates: [])
    }

    init(habit: String, streak: Int, dates: [Date], timeToRemind: String, imageUrls: [String], uncheckedImageUrls: [String], uncheckedDates: [Date], rejectedDates: [String]) {
        self.habit = habit
        self.streak = streak
        self.timeToRemind = timeToRemind
        self.dates = dates
        self.imageUrls = imageUrls
        self.uncheckedImageUrls = uncheckedImageUrls
        self.uncheckedDates = uncheckedDates
        self.rejectedDates = rejectedDates
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
    
    func computeStreakLength() -> Int {
        let habit = self
        let rejectedDatesAsStrings = habit.rejectedDates
        var datesAsStrings = [String]()
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        for date in habit.dates {
            datesAsStrings.append(format.string(from: date))
        }
        
        var result = 0
        var date = Date()
        
        // Today is a special day. Dont cancel streak if today is not yet done
        if taskCompletedOnDate(date: format.string(from: date), dates: datesAsStrings, rejectedDates: rejectedDatesAsStrings) {
            result = 1
        }
        
        if rejectedDatesAsStrings.contains(format.string(from: date)) {
            return result
        }
        
        // Set date to yesterday
        date = Calendar.current.date(byAdding: .day, value: -1, to: date)!
        
        while taskCompletedOnDate(date: format.string(from: date), dates: datesAsStrings, rejectedDates: rejectedDatesAsStrings) {
            result += 1
            date = Calendar.current.date(byAdding: .day, value: -1, to: date)!
        }

        return result
    }
    
    func taskCompletedOnDate(date: String, dates:[String], rejectedDates:[String]) -> Bool {
        return dates.contains(date) && !rejectedDates.contains(date)
    }

    
    func convertToJSON() -> [String: String] {
        return [
            "habit": self.habit,
            "streak": String(self.streak),
            "timeToRemind": self.timeToRemind,
            "dates": self.stringifyDateArray(datesParam: self.dates).joined(separator: ","),
            "imageUrls": self.imageUrls.joined(separator: ","),
            "uncheckedImageUrls": self.uncheckedImageUrls.joined(separator: ","),
            "uncheckedDates": self.stringifyDateArray(datesParam: self.uncheckedDates).joined(separator: ","),
            "rejectedDates": self.rejectedDates.joined(separator: ",")
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
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        for date in strList {
            if date != "" {
                result.append(dateFormatterGet.date(from: date)!)
            }
        }
        return result
    }
    
    static func convertDateListToStringList(dates: [Date]) -> [String] {
        var result: [String] = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        for date in dates {
            result.append(dateFormatter.string(from: date))
        }
        return result
    }
}
