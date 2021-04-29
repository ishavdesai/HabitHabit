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


class HistoryViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var habitLabel: UILabel!
    @IBOutlet weak var calendarView: FSCalendar!
    private var collectionView: UICollectionView?
    
    var collectionViewImages: [UIImage] = []
    var habits: [Habit] = []
    var habitsOnDate: [Date: [(Habit, Int)]] = [:]
    private let database: DatabaseReference = Database.database().reference()
    private let databaseUsernameKey: String = UserDefaults.standard.string(forKey: "kUsername") ?? "USERNAME_DATABASE_KEY_ERROR"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.habit.purple
        self.dateLabel.textColor = .white
        self.habitLabel.textColor = .white
        
        self.calendarView.dataSource = self
        self.calendarView.delegate = self
        self.calendarView.backgroundColor = .white
        self.calendarView.layer.cornerRadius = 5
        self.loadUserData()
        self.setupCollectionView()
    }
    
    private func setupCollectionView() -> Void {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (view.frame.size.width / 3) - 3, height: (view.frame.size.width / 3) - 3)
        layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.collectionView?.register(HistoryCollectionViewCell.self, forCellWithReuseIdentifier: HistoryCollectionViewCell.identifier)
        self.collectionView?.showsHorizontalScrollIndicator = false
        self.collectionView?.backgroundColor = self.view.backgroundColor
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        guard let myCollection = self.collectionView else { return }
        view.addSubview(myCollection)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let y_offset: CGFloat = 550
        self.collectionView?.frame = CGRect(x: 0, y: y_offset, width: view.frame.size.width, height: view.frame.size.height - y_offset).integral
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.collectionViewImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView?.dequeueReusableCell(withReuseIdentifier: HistoryCollectionViewCell.identifier, for: indexPath as IndexPath) as! HistoryCollectionViewCell
        cell.configure(image: self.collectionViewImages[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
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
    
    // remove all the added subviews (images)
    func removeImages() {
        for subview in self.view.subviews {
            if subview.tag == 130 {
                subview.removeFromSuperview()
            }
        }
    }
    
    // When the user taps a date, the habits on that date will be displayed below
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.removeImages()
        self.collectionViewImages.removeAll()
        self.collectionView?.reloadData()
        let tmpDate = Calendar(identifier: .gregorian)
        let year = tmpDate.component(.year, from: date)
        let month = tmpDate.component(.month, from: date)
        let day = tmpDate.component(.day, from: date)
        dateLabel.text = "Date: \(month)/\(day)/\(year)"

        var habitsText = "Habit(s): "
        if self.habitsOnDate[date] != nil {
            for habitAndIndex in self.habitsOnDate[date]! {
                let habit = habitAndIndex.0
                let imageIndex = habitAndIndex.1
                habitsText += habit.toString() + ", "
                let image: UIImage? = self.findImageForSpecifiedDate(habit: habit, imageIndex: imageIndex, date: date) // replace with above
                if image != nil {
                    self.collectionViewImages.append(image!)
                }
            }
            // cut off the last ", "
            habitsText = String(habitsText.dropLast(2))
        }
        self.habitLabel.text = habitsText
        self.collectionView?.reloadData()
    }
    
    private func findImageForSpecifiedDate(habit: Habit, imageIndex: Int, date: Date) -> UIImage? {
        let imageDates: [ImageDatePair] = UtilityClass.habitNameUpdateDict[habit.habit] ?? []
        var dateSpecificImages: [UIImage] = []
        for imageDate in imageDates {
            if Calendar.current.isDate(imageDate.date, inSameDayAs: date) {
                dateSpecificImages.append(imageDate.image)
            }
        }
        if dateSpecificImages.count == 0 {
            return nil
        } else {
            return dateSpecificImages[0]
        }
    }
    
    // Indicates how many habits the user has updated on a date with dots below the day
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        self.habitsOnDate[date]?.removeAll()
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
    
    func dateFormat(date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func loadUserData() -> Void {
        self.database.child(self.databaseUsernameKey).child("Habit").observe(.value) {
            snapshot in
            for case let child as DataSnapshot in snapshot.children {
                guard let value = child.value as? [String: String] else {
                    return
                }
                let (habitExists, habit): (Bool, Habit?) = UtilityClass.makeHabit(value: value)
                if habitExists {
//-------------For test (delete later)---------------------------------------------------------
//                    habit!.imageUrls.append("DefaultPeerHabit")
//                    habit!.dates.append(Date())
//---------------------------------------------------------------------------------------------
                    self.habits.append(habit!)
                }
            }
        }
    }
}
