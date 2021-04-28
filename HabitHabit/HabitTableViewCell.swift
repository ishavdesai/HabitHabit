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
        self.streak = self.habit!.computeStreakLength()
        self.streakLabel.text = String(self.streak)
        if(!noCamera) {
            let image: UIImage? = UIImage(systemName: "camera")
            self.cameraButton.setBackgroundImage(image, for: .normal)
            self.cameraButton.setTitle("", for: .normal)
        }
        self.delegate = delegate
        
        UIDesign.setCellProperties(cell: self)
    }
        
    @IBAction func cameraButtonClicked(_ sender: Any) {
        self.delegate?.takePictureAndUpdateHabit(habit: self.habit!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
    }
}
