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
    
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return pages.count
    }

    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "HOME"
        //self.tabBarItem.image = UIImage(named: "item")
        //self.tabBarItem.selectedImage = UIImage(named: "item_selected")
        // Do any additional setup after loading the view.
        self.dataSource = self
        self.delegate = self
        let initialPage = 0
        
        var pagesToAdd: [VariableViewController] = []
        self.database.child(self.databaseUsernameKey).child("Habit").observeSingleEvent(of: .value) {
            snapshot in
            for case let child as DataSnapshot in snapshot.children {
                guard let value = child.value as? [String: String] else {
                    return
                }
                let habit: String = value["habit"] ?? "NO_HABIT_EXISTS"
                let streak: Int = Int(value["streak"] ?? "") ?? -1
                if habit != "NO_HABIT_EXISTS" && streak != -1 {
                    pagesToAdd.append(VariableViewController(pageNum: pagesToAdd.count + 1, habitName: habit, streak: streak))
                }
            }
            
            // TODO Make a new view controller in case there are no habits for an account
            if pagesToAdd.count == 0 {
                pagesToAdd.append(VariableViewController(pageNum: -1, habitName: "Default Screen", streak: -1))
            }
            
            // add the individual viewControllers to the pageViewController
            for variableVC in pagesToAdd {
                self.pages.append(variableVC)
                print(self.pages.count)
            }
            self.setViewControllers([self.pages[initialPage]], direction: .forward, animated: true, completion: nil)
            
            // pageControl
            self.pageControl.frame = CGRect()
            self.pageControl.currentPageIndicatorTintColor = UIColor.black
            self.pageControl.pageIndicatorTintColor = UIColor.lightGray
            self.pageControl.numberOfPages = self.pages.count
            self.pageControl.currentPage = initialPage
            self.view.addSubview(self.pageControl)
            
            self.pageControl.translatesAutoresizingMaskIntoConstraints = false
            self.pageControl.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -5).isActive = true
            self.pageControl.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -20).isActive = true
            self.pageControl.heightAnchor.constraint(equalToConstant: 20).isActive = true
            self.pageControl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        }
    }
}
