//
//  OnboardingViewController.swift
//  HabitHabit
//
//  Created by Ally on 5/4/21.
//

import UIKit

class OnboardingViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        
    var pages = [UIViewController]()
    
    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.backgroundColor = UIColor.habit.purple
        pageControl.currentPageIndicatorTintColor = .systemPink
        pageControl.pageIndicatorTintColor = .systemGray5
        return pageControl
    }()
    
    private let databaseUsernameKey: String = UserDefaults.standard.string(forKey: "kUsername") ?? "USERNAME_DATABASE_KEY_ERROR"
    let landingPageSegue: String = "ContinueToLandingPage"

    private var titleText: [String]!
    private var subtitleText: [String]!
    var segueButton: UIButton?
    
    
    @objc private func goToLandingPage(_ sender: Any) -> Void {
        let pulse = ButtonPulseAnimation(numberOfPulses: 1, radius: 200, position: self.view.center)
        pulse.animationDuration = 1.0
        pulse.backgroundColor = UIColor.habit.orange.cgColor
        self.view.layer.insertSublayer(pulse, below: self.view.layer)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.performSegue(withIdentifier: self.landingPageSegue, sender: nil)
        }
    }
    
    private func setupTextForOnboarding() -> Void {
        self.titleText = ["Welcome To HabitHabit!", "Achieve Goals", "Features"]
        self.subtitleText = ["Hi \(self.databaseUsernameKey)! Thank you for downloading HabitHabit!", "Here at HabitHabit, we hope to help you achieve your goals and help you keep yourself accountable. Work hard and accomplish your goals!", "Add habits, track them with pictures, and add friends and help hold each other accountable!"]
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self
        self.delegate = self
        
        setupTextForOnboarding()
        
        self.segueButton = UIButton()
        self.segueButton?.backgroundColor = .black
        self.segueButton?.tintColor = UIColor.habit.orange
        self.segueButton?.setTitle("Go to app!", for: .normal)
        self.segueButton?.translatesAutoresizingMaskIntoConstraints = false

        self.segueButton?.addTarget(self, action: #selector(self.goToLandingPage(_:)), for: .touchUpInside)
        UIDesign.cleanupButton(button: self.segueButton)
        
        let initialPage = 0
        let page1 = TutorialTipsViewController(titleText: self.titleText[0], subtitleText: self.subtitleText[0], button: UIButton())
        let page2 = TutorialTipsViewController(titleText: self.titleText[1], subtitleText: self.subtitleText[1], button: UIButton())
        let page3 = TutorialTipsViewController(titleText: self.titleText[2], subtitleText: self.subtitleText[2], button: self.segueButton)
                
        // add the individual viewControllers to the pageViewController
        self.pages.append(page1)
        self.pages.append(page2)
        self.pages.append(page3)
        setViewControllers([pages[initialPage]], direction: .forward, animated: true, completion: nil)

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
    
}
