//
//  HabitImageMagnifierViewController.swift
//  HabitHabit
//
//  Created by Ishav Desai on 4/12/21.
//

import UIKit

class HabitImageMagnifierViewController: UIViewController {
    
    var viewTitle: String?
    var image: UIImage?
    var updateStatus: Bool?
    var habitName: String?
    @IBOutlet weak var habitNameLabel: UILabel!
    @IBOutlet weak var habitUpdateStatusLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.habit.purple
        self.title = self.viewTitle!
        self.imageView.image = self.image!
        self.habitNameLabel?.text = "Habit Name: \(self.habitName!)"
        if self.updateStatus == nil {
            self.habitUpdateStatusLabel?.text = "This habit update has not been verified by a peer yet"
        } else {
            self.habitUpdateStatusLabel?.text = "This habit update was \(self.updateStatus! ? "rejected" : "accepted")."
        }
        self.habitNameLabel?.textColor = .white
        self.habitUpdateStatusLabel?.textColor = .white
    }
    
}
