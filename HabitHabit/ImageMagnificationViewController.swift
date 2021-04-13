//
//  ImageMagnificationViewController.swift
//  HabitHabit
//
//  Created by Dime Iwata on 4/9/21.
//

import UIKit

class ImageMagnificationViewController: UIViewController {
    
    var peerObject: Habit!
    var row: Int!
    
    var delegate: UIViewController!
    
    @IBOutlet weak var habitImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var habitNameLabel: UILabel!
    @IBOutlet weak var streakLabel: UILabel!
    @IBOutlet weak var failuresLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 119/255, green: 33/255, blue: 111/255, alpha: 1)

        // Set the labels' texts using the Habit class object
//        self.userNameLabel.text = self.peerObject.user
        self.habitNameLabel.text = self.peerObject.habit
        self.streakLabel.text = String(self.peerObject.streak) + " days"
//        self.failuresLabel.text = String(self.peerObject.failures)
//        self.dateLabel.text = dateToString(self.peerObject.date)
    }
    
    @IBAction func checkPressed(_ sender: Any) {
        // that habit's approved count is incremented and delete the peer's habit from the list
        let prevVC = delegate as! peerHabitDeleter
        prevVC.deleteFromPeerList(row: self.row)
    }
    
    @IBAction func denyPressed(_ sender: Any) {
        // that habit's denied count is incremented and delete the peer's habit from the list
        let prevVC = delegate as! peerHabitDeleter
        prevVC.deleteFromPeerList(row: self.row)
    }
    
    // convert date object into string
//    func dateToString(date: Date) -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "dd MMM YYYY"
//        return dateFormatter.string(from: date)
//    }
    
}
