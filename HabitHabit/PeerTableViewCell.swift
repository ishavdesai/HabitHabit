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
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
