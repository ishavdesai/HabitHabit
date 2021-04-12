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
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.viewTitle!
        self.imageView.image = self.image!
    }

}
