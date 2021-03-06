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
    var imageDateList: [ImageDatePair] = []
    @IBOutlet weak var habitCountLabel: UILabel!
    let habitImageMagnifierSegue: String = "HabitImageMagnifierSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.habit.purple
        self.title = self.habit?.habit
        habitCountLabel.text = String(self.habit?.computeStreakLength() ?? 0)
        self.imageDateList = UtilityClass.habitNameUpdateDict[self.habit!.habit]!
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
        return self.imageDateList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView?.dequeueReusableCell(withReuseIdentifier: HabitImageCircleCollectionViewCell.identifier, for: indexPath as IndexPath) as! HabitImageCircleCollectionViewCell
        cell.configure(image: self.imageDateList[indexPath.row].image)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let date = self.imageDateList[indexPath.row].date
        let image = self.imageDateList[indexPath.row].image
        let uncheckedDate = self.habit!.uncheckedDates
        let rejectedDate: [Date] = Habit.convertStringListToDateList(strList: self.habit!.rejectedDates)
        var updateStatus: Bool?
        if uncheckedDate.contains(date) {
            updateStatus = nil
        } else {
            updateStatus = UtilityClass.dateListSameAsDate(dateList: rejectedDate, date: date)
        }
        let df = DateFormatter()
        df.dateFormat = "LLLL dd, yyyy"
        let titleToPass: String = df.string(from: date)
        self.performSegue(withIdentifier: self.habitImageMagnifierSegue, sender: (image, titleToPass, updateStatus, self.habit!.habit))
        self.collectionView?.deselectItem(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.habitImageMagnifierSegue,
           let destination = segue.destination as? HabitImageMagnifierViewController,
           let (image, titleToPass, updateStatus, habitName): (UIImage, String, Bool?, String) = sender as? (UIImage, String, Bool?, String) {
            destination.viewTitle = titleToPass
            destination.image = image
            destination.updateStatus = updateStatus
            destination.habitName = habitName
        }
    }
    
}
