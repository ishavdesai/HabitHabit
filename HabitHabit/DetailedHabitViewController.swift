//
//  DetailedHabitViewController.swift
//  HabitHabit
//
//  Created by Shreyas Amargol on 4/10/21.
//

import UIKit

class DetailedHabitViewController: UIViewController {
    
    var habit:Habit?
    @IBOutlet weak var habitNameLabel: UILabel!
    @IBOutlet weak var habitCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        habitNameLabel.text = habit?.habit
        habitCountLabel.text = String(habit?.streak ?? 0)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
