//
//  UIDesign.swift
//  HabitHabit
//
//  Created by Ally on 4/22/21.
//

import Foundation
import UIKit

class UIDesign {
    
    static func cleanupButton(button: UIButton!) -> Void {
        
        
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor(red: 132/255, green: 55/255, blue: 135/255, alpha: 1).cgColor
        button.layer.backgroundColor = UIColor(red: 132/255, green: 55/255, blue: 135/255, alpha: 0.75).cgColor
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 4
        button.layer.shadowRadius = 3
        button.layer.shadowOpacity = 0.5
        button.layer.shadowOffset = CGSize(width: 4, height: 4)
        button.layer.frame = CGRect(x: button.layer.frame.origin.x, y: button.layer.frame.origin.y, width: 300, height: 30)
        
    }
}
