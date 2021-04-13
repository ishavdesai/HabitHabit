//
//  PeerTableViewCell.swift
//  HabitHabit
//
//  Created by Dime Iwata on 4/10/21.
//

import UIKit

class PeerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var denyButton: UIButton!
    @IBOutlet weak var habitImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        contentView.backgroundColor = UIColor(red: 119/255, green: 33/255, blue: 111/255, alpha: 1)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
