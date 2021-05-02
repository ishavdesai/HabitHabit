//
//  ImageDatePair.swift
//  HabitHabit
//
//  Created by Ishav Desai on 4/27/21.
//

import Foundation
import UIKit

class ImageDatePair {
    let image: UIImage
    let date: Date
    
    init(image: UIImage, date: Date) {
        self.image = image
        self.date = date
    }
    
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    
    func compare(_ other: ImageDatePair) -> Bool {
        return self.date > other.date
    }
}
