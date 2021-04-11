//
//  VariablePageViewController.swift
//  HabitHabit-Zach
//
//  Created by Zach on 3/26/21.
//

//REFERENCE: https://www.linkedin.com/pulse/using-ios-pageviewcontroller-without-storyboards-paul-tangen

import UIKit
import FirebaseDatabase

class LandingPageViewController: UIPageViewController,
                                 UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    
    var pages = [UIViewController]()
    let pageControl = UIPageControl()
    var currentIndex: Int?
    private var pendingIndex: Int?
    private let databaseUsernameKey: String = UserDefaults.standard.string(forKey: "kUsernameDatabaseKey") ?? "USERNAME_DATABASE_KEY_ERROR"
    private let database: DatabaseReference = Database.database().reference()
    private var habitsList: [Habit] = []
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return pages.count
    }

    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        pendingIndex = navigationController?.viewControllers.firstIndex(of: self)
    }

    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            currentIndex = pendingIndex
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if let viewControllerIndex = self.pages.firstIndex(of: viewController) {
            if viewControllerIndex == 0 {
                // wrap to last page in array
                return self.pages.last
            } else {
                // go to previous page in array
                return self.pages[viewControllerIndex - 1]
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if let viewControllerIndex = self.pages.firstIndex(of: viewController) {
            if viewControllerIndex < self.pages.count - 1 {
                // go to next page in array
                return self.pages[viewControllerIndex + 1]
            } else {
                // wrap to first page in array
                return self.pages.first
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        // set the pageControl.currentPage to the index of the current viewController in pages
        if let viewControllers = pageViewController.viewControllers {
            if let viewControllerIndex = self.pages.firstIndex(of: viewControllers[0]) {
                self.pageControl.currentPage = viewControllerIndex
            }
        }
    }
    
    private func makeHabit(value: [String: String]) -> (Bool, Habit?) {
        let habit: String = value["habit"] ?? "NO_HABIT_EXISTS"
        let timeToRemind: String = value["timeToRemind"] ?? "NO_TIME_TO_REMIND"
        let streak: Int = Int(value["streak"] ?? "") ?? -1
        let dateString: String = value["dates"] ?? ""
        let dates: [Date] = (dateString.count == 0) ? [] : Habit.convertStringListToDateList(strList: dateString.components(separatedBy: ","))
        let habitExists: Bool = habit != "NO_HABIT_EXISTS" && streak != -1 && timeToRemind != "NO_TIME_TO_REMIND"
        let habitResult: Habit? = habitExists ? Habit(habit: habit, streak: streak, dates: dates, timeToRemind: timeToRemind) : nil
        return (habitExists, habitResult)
    }
    
    private func readFromDatabase() -> Void {
        let initialPage = 0
        var pagesToAdd: [VariableViewController] = []

        self.database.child(self.databaseUsernameKey).child("Habit").observe(.value) {
            snapshot in
            for case let child as DataSnapshot in snapshot.children {
                guard let value = child.value as? [String: String] else {
                    return
                }
                let (habitExists, habit): (Bool, Habit?) = self.makeHabit(value: value)
                if habitExists {
                    self.habitsList.append(habit!)
                }
            }
            
            for (index, habit) in self.habitsList.enumerated() {
                // dont change pagenum:index+1
                pagesToAdd.append(VariableViewController(pageNum: index + 1, habitName: habit.habit, streak: habit.streak))
            }
            
            // uundo to this
            /* NOTE FROM ZACH: Commenting might break, testing
            pagesToAdd.append(VariableViewController(pageNum: self.habitsList.count + 1, habitName: "Add a habit", streak: -1))
            */
            
            // add the individual viewControllers to the pageViewController
            for variableVC in pagesToAdd {
                self.pages.append(variableVC)
                print(self.pages.count)
            }
            
            if self.pages.count == 0 {
                self.pages.append(CreateHabitVariableViewController())
                self.pages.append(CreateHabitVariableViewController())
            }
            
            if self.pages.count == 1 {
                self.pages.append(CreateHabitVariableViewController())
            }
            
            self.setViewControllers([self.pages[initialPage]], direction: .forward, animated: false, completion: nil)
            // pageControl
            self.pageControl.frame = CGRect()
            self.pageControl.currentPageIndicatorTintColor = UIColor.black
            self.pageControl.pageIndicatorTintColor = UIColor.lightGray
            self.pageControl.numberOfPages = self.habitsList.count
            self.pageControl.currentPage = initialPage
            self.view.addSubview(self.pageControl)
            
            self.pageControl.translatesAutoresizingMaskIntoConstraints = false
            self.pageControl.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -5).isActive = true
            self.pageControl.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -20).isActive = true
            self.pageControl.heightAnchor.constraint(equalToConstant: 20).isActive = true
            self.pageControl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        
        //self.readFromDatabase()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.readFromDatabase()
        self.dataSource = self
        super.viewDidAppear(animated)
        print("Reading from database")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.habitsList.removeAll()
        self.pages.removeAll()
        self.dataSource = nil
        print("Cleared local data")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.dataSource = self
        print("Tachibana Rui")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.dataSource = nil
    }
    
    func refreshView() {
        self.habitsList.removeAll()
        self.pages.removeAll()
        self.dataSource = nil
        self.dataSource = self
        self.readFromDatabase()
        print("Refreshed!")
    }
    
}
