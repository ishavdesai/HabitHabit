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
    
    private var streak: Int = 0
    
    func setProperties(name: String, streak: Int) {
        self.nameLabel.text = name
        self.streakLabel.text = String(streak)
        
        self.streak = streak
    }

    @IBAction func onToggle(_ sender: UISwitch) {
        if sender.isOn {
            self.streak += 1
        } else {
            self.streak -= 1
        }
        
        self.streakLabel.text = String(self.streak)
    }
}
