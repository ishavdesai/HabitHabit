//
//  HistoryViewController.swift
//  HabitHabit
//
//  Created by Dime Iwata on 4/26/21.
//

import Foundation
import UIKit
import FirebaseDatabase
import FSCalendar
import CalculateCalendarLogic


class HistoryViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var habitLabel: UILabel!
    @IBOutlet weak var calendarView: FSCalendar!
    
    var habits: [Habit] = []
    var habitsOnDate: [Date: [(Habit, Int)]] = [:]
    private let database: DatabaseReference = Database.database().reference()
    private let databaseUsernameKey: String = UserDefaults.standard.string(forKey: "kUsername") ?? "USERNAME_DATABASE_KEY_ERROR"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 119/255, green: 33/255, blue: 111/255, alpha: 1)
        self.dateLabel.textColor = .white
        self.habitLabel.textColor = .white
        
        self.calendarView.dataSource = self
        self.calendarView.delegate = self
        
        self.calendarView.reloadData()
        self.loadUserData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.calendarView.reloadData()
    }
    
    @IBAction func prevPressed(_ sender: Any) {
        calendarView.setCurrentPage(getPrevMonth(date: calendarView.currentPage), animated: true)
    }
    
    @IBAction func nextPressed(_ sender: Any) {
        calendarView.setCurrentPage(getNextMonth(date: calendarView.currentPage), animated: true)
    }
    
    func getPrevMonth(date: Date) -> Date {
        return Calendar.current.date(byAdding: .month, value: -1, to: date)!
    }
    
    func getNextMonth(date: Date) -> Date {
        return Calendar.current.date(byAdding: .month, value: 1, to: date)!
    }
    
    // When the user taps a date, the habits on that date will be displayed below
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let tmpDate = Calendar(identifier: .gregorian)
        let year = tmpDate.component(.year, from: date)
        let month = tmpDate.component(.month, from: date)
        let day = tmpDate.component(.day, from: date)
        dateLabel.text = "Date: \(month)/\(day)/\(year)"
        
        var imagePosition = (40, 600)
        var habitsText = "Habit: "
        if self.habitsOnDate[date] != nil {
            for habitAndIndex in self.habitsOnDate[date]! {
                let habit = habitAndIndex.0
                let imageIndex = habitAndIndex.1
                habitsText += habit.toString() + ", "
                
                // load a picture of habit activity
                let image = self.getImage(imageUrl: habit.imageUrls[imageIndex])
                let imageView = UIImageView(image: image)
                imageView.frame = CGRect(x: imagePosition.0, y: imagePosition.1, width: 100, height: 60)
                view.addSubview(imageView)
                imagePosition.0 += 120
                if imagePosition.0 == 400 {
                    imagePosition.0 = 40
                    imagePosition.1 += 80
                }
            }
            // cut off the last ", "
            habitsText = String(habitsText.dropLast(2))
        }
        self.habitLabel.text = habitsText
    }
    
    // Indicates how many habits the user has updated on a date with dots below the day
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        var countHabit = 0
        for habit in self.habits {
            var imageIndex = 0
            for d in habit.dates {
                if dateFormat(date: d) == dateFormat(date: date) {
                    countHabit += 1
                    if self.habitsOnDate[date] == nil {
                        self.habitsOnDate[date] = [(habit, imageIndex)]
                    } else {
                        self.habitsOnDate[date]!.append((habit, imageIndex))
                    }
                }
                imageIndex += 1
            }
        }
        return countHabit
    }
    
    private func loadUserData() -> Void {
        self.database.child(self.databaseUsernameKey).child("Habit").observe(.value) {
            snapshot in
            for case let child as DataSnapshot in snapshot.children {
                guard let value = child.value as? [String: String] else {
                    return
                }
                let (habitExists, habit): (Bool, Habit?) = HabitMaker.makeHabit(value: value)
                if habitExists {
                    self.habits.append(habit!)
                }
            }
        }
    }
    
    func dateFormat(date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    func getImage(imageUrl: String) -> UIImage {
        var result: UIImage!
        let sem = DispatchSemaphore.init(value: 0)
        let task = URLSession.shared.dataTask(with: URL(string: imageUrl)!, completionHandler: {
            data, _, error in
            guard let data = data, error == nil else { return }
            result = UIImage(data: data)!
            sem.signal()
        })
        task.resume()
        sem.wait()
        return result
    }
}
