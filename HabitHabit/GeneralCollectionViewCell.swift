//
//  GeneralCollectionViewCell.swift
//  HabitHabit
//
//  Created by Ishav Desai on 4/28/21.
//

import UIKit

class GeneralCollectionViewCell: UICollectionViewCell {
    private let habitImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .systemBlue
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(self.habitImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.habitImageView.frame = contentView.bounds
    }
    
    public func configure(image: UIImage) {
        self.habitImageView.image = image
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.habitImageView.image = nil
    }
}
