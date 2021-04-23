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
        
        UIDesign.setCellProperties(cell: self)
        
        // UI Cell changes
        /*
        backgroundColor = .clear // very important
        layer.masksToBounds = false
        // layer.shadowOpacity = 0.23
        // layer.shadowRadius = 4
        // layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowColor = UIColor.black.cgColor
        contentView.layer.cornerRadius = 10
        // add corner radius on `contentView`
        contentView.backgroundColor = UIColor(red: 88/255, green: 86/255, blue: 214/255, alpha: 1)
        contentView.layer.cornerRadius = 10
        */
    }
    
    @IBAction func cameraButtonClicked(_ sender: Any) {
        self.delegate?.takePictureAndUpdateHabit(habit: self.habit!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
    }
}
