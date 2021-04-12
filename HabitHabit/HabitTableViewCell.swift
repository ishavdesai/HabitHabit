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
    
    func setProperties(habit: Habit, delegate: HabitImageTrackerDelegate) {
        self.habit = habit
        self.nameLabel.text = self.habit!.habit
        self.streakLabel.text = String(self.habit!.streak)
        self.streak = self.habit!.streak
        let image: UIImage? = UIImage(systemName: "camera")
        self.cameraButton.setBackgroundImage(image, for: .normal)
        self.cameraButton.setTitle("", for: .normal)
        self.delegate = delegate
    }
    
    @IBAction func cameraButtonClicked(_ sender: Any) {
        self.delegate?.takePictureAndUpdateHabit(habit: self.habit!)
    }
    
}
