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
        button.layer.borderColor = UIColor(red: 132/255, green: 55/255, blue: 135/255, alpha: 1).cgColor
        button.layer.backgroundColor = UIColor(red: 132/255, green: 55/255, blue: 135/255, alpha: 0.75).cgColor
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
        cell.backgroundColor = .clear // very important
        cell.layer.masksToBounds = false
        // layer.shadowOpacity = 0.23
        // layer.shadowRadius = 4
        // layer.shadowOffset = CGSize(width: 0, height: 0)
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.contentView.layer.cornerRadius = 10
        // add corner radius on `contentView`
        cell.contentView.backgroundColor = UIColor(red: 88/255, green: 86/255, blue: 214/255, alpha: 1)
        cell.contentView.layer.cornerRadius = 10
        cell.textLabel?.textColor = .white
    }
}
