//
//  HabitTableViewCell.swift
//  HabitHabit
//
//  Created by Shreyas Amargol on 3/30/21.
//

import UIKit

class HabitTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var streakLabel: UILabel!
    @IBOutlet weak var cameraButton: UIButton!
    private var streak: Int = 0
    private var habit: Habit? = nil
    var delegate: HabitImageTrackerDelegate?
    
    func setProperties(habit: Habit, delegate: HabitImageTrackerDelegate, noCamera:Bool = false) {
        self.habit = habit
        self.nameLabel.text = self.habit!.habit
        self.streakLabel.text = String(self.habit!.streak)
        self.streak = self.habit!.streak
        self.streak = computeStreakLength(habit: self.habit!)
        self.streakLabel.text = String(self.streak)
        if(!noCamera) {
            let image: UIImage? = UIImage(systemName: "camera")
            self.cameraButton.setBackgroundImage(image, for: .normal)
            self.cameraButton.setTitle("", for: .normal)
        }
        self.delegate = delegate
        
        UIDesign.setCellProperties(cell: self)
    }
    
    func computeStreakLength(habit: Habit) -> Int {
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
    
    @IBAction func cameraButtonClicked(_ sender: Any) {
        self.delegate?.takePictureAndUpdateHabit(habit: self.habit!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
    }
}
