//
//  DetailedHabitViewController.swift
//  HabitHabit
//
//  Created by Shreyas Amargol on 4/10/21.
//

import UIKit

class DetailedHabitViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private var collectionView: UICollectionView?
    var habit: Habit?
    var habitImages: [UIImage] = []
    @IBOutlet weak var habitCountLabel: UILabel!
    let habitImageMagnifierSegue: String = "HabitImageMagnifierSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.habit.purple
        self.title = self.habit?.habit
        habitCountLabel.text = String(self.habit?.computeStreakLength() ?? 0)
        self.habitImages = UtilityClass.getAllImagesOnly(imageDateList: UtilityClass.habitNameUpdateDict[self.habit!.habit]!)
        self.setupCollectionView()
    }
    
    private func setupCollectionView() -> Void {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (view.frame.size.width / 3) - 3, height: (view.frame.size.width / 3) - 3)
        layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.collectionView?.register(HabitImageCircleCollectionViewCell.self, forCellWithReuseIdentifier: HabitImageCircleCollectionViewCell.identifier)
        self.collectionView?.showsHorizontalScrollIndicator = false
        self.collectionView?.backgroundColor = self.view.backgroundColor
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        guard let myCollection = self.collectionView else { return }
        view.addSubview(myCollection)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.collectionView?.frame = CGRect(x: 0, y: 200, width: view.frame.size.width, height: view.frame.size.height - 200).integral
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.habitImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView?.dequeueReusableCell(withReuseIdentifier: HabitImageCircleCollectionViewCell.identifier, for: indexPath as IndexPath) as! HabitImageCircleCollectionViewCell
        cell.configure(image: self.habitImages[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let date = self.habit!.dates[indexPath.row]
        let image = self.habitImages[indexPath.row]
        let df = DateFormatter()
        df.dateFormat = "LLLL dd, yyyy"
        let titleToPass: String = df.string(from: date)
        self.performSegue(withIdentifier: self.habitImageMagnifierSegue, sender: (image, titleToPass))
        self.collectionView?.deselectItem(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.habitImageMagnifierSegue,
           let destination = segue.destination as? HabitImageMagnifierViewController {
            let (image, titleToPass): (UIImage, String) = sender as! (UIImage, String)
            destination.viewTitle = titleToPass
            destination.image = image
        }
    }
    
}
