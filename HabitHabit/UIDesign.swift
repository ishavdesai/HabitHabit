//
//  UIDesign.swift
//  HabitHabit
//
//  Created by Ally on 4/22/21.
//

import Foundation
import UIKit

class UIDesign {
    
    static func cleanupButton(button: UIButton!, dontAdjustText: Bool = false) -> Void {
        
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.darkGray.cgColor
        button.layer.backgroundColor = UIColor.darkGray.cgColor
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 4
        button.layer.shadowRadius = 3
        button.layer.shadowOpacity = 0.5
        button.layer.shadowOffset = CGSize(width: 4, height: 4)
        if(!dontAdjustText) {
            button.setTitle(adjustText(text: button.currentTitle!), for: .normal)
        }
        
    }
    
    static func adjustText(text:String) -> String {
        let padding:Int = 30
        var result:String = text
        for _ in 0...(padding - text.count) {
            result = " " + result + " "
        }
        return result
    }
    
    static func setCellProperties(cell:UITableViewCell) -> Void {
        cell.backgroundColor = .clear
        cell.layer.masksToBounds = false
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.backgroundColor = UIColor.habit.cellBlue
        cell.contentView.layer.cornerRadius = 10
        cell.textLabel?.textColor = .white
    }
}

extension UIColor {
    struct habit {
        static var purple: UIColor { return UIColor(red: 119/255, green: 33/255, blue: 111/255, alpha: 1) }
        static var darkPurple: UIColor { return UIColor(red: 44/255, green: 0/255, blue: 30/255, alpha: 1) }
        static var midPurple: UIColor { return UIColor(red: 132/255, green: 55/255, blue: 135/255, alpha: 1) }
        static var orange: UIColor { return UIColor(red: 233/255, green: 84/255, blue: 32/255, alpha: 1) }
        static var cellBlue: UIColor { return UIColor(red: 88/255, green: 86/255, blue: 214/255, alpha: 1) }
    }
}
