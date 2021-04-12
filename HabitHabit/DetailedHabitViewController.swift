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
        self.title = habit?.habit
        habitCountLabel.text = String(habit?.streak ?? 0)
        self.habitImages = self.getHabitImagesFromDatabase()
        self.setupCollectionView()
    }
    
    private func getHabitImagesFromDatabase() -> [UIImage] {
        var result: [UIImage] = []
        let sem = DispatchSemaphore.init(value: 0)
        let imageUrls = self.habit!.imageUrls
        for index in 0..<imageUrls.count {
            guard let url = URL(string: imageUrls[index]) else { return result }
            let task = URLSession.shared.dataTask(with: url, completionHandler: {
                data, _, error in
                defer {
                    if index == imageUrls.count - 1 {
                        sem.signal()
                    }
                }
                guard let data = data, error == nil else { return }
                result.append(UIImage(data: data)!)
            })
            task.resume()
        }
        sem.wait()
        return result
    }
    
    private func setupCollectionView() -> Void {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 150, height: 150)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.collectionView?.register(HabitImageCircleCollectionViewCell.self, forCellWithReuseIdentifier: HabitImageCircleCollectionViewCell.identifier)
        self.collectionView?.showsHorizontalScrollIndicator = false
        self.collectionView?.backgroundColor = .white
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        guard let myCollection = self.collectionView else { return }
        view.addSubview(myCollection)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.collectionView?.frame = CGRect(x: 0, y: 200, width: view.frame.size.width, height: 150).integral
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.habitImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView?.dequeueReusableCell(withReuseIdentifier: HabitImageCircleCollectionViewCell.identifier, for: indexPath as IndexPath) as! HabitImageCircleCollectionViewCell
        cell.configure(image: self.habitImages[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let date = self.habit!.dates[indexPath.row]
        let image = self.habitImages[indexPath.row]
        let df = DateFormatter()
        df.dateFormat = "LLLL dd, yyyy"
        let titleToPass: String = df.string(from: date)
        self.performSegue(withIdentifier: self.habitImageMagnifierSegue, sender: (image, titleToPass))
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