//
//  OnboardingViewController.swift
//  HabitHabit
//
//  Created by Ishav Desai on 5/2/21.
//

import UIKit

class OnboardingViewController: UIViewController, UIScrollViewDelegate {
    
    private let databaseUsernameKey: String = UserDefaults.standard.string(forKey: "kUsername") ?? "USERNAME_DATABASE_KEY_ERROR"
    private let scrollView = UIScrollView()
    let landingPageSegue: String = "ContinueToLandingPage"
    private let pageControl: UIPageControl = {
       let pageControl = UIPageControl()
        pageControl.numberOfPages = 3
        pageControl.backgroundColor = UIColor.habit.purple
        pageControl.currentPageIndicatorTintColor = .systemPink
        pageControl.pageIndicatorTintColor = .systemGray5
        return pageControl
    }()
    private var titleText: [String]!
    private var subtitleText: [String]!
    let titleLabels: [UILabel] = [UILabel(), UILabel(), UILabel()]
    let bodyLabels: [UILabel] = [UILabel(), UILabel(), UILabel()]
    var segueButton: UIButton?
    var pages: [UIView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTextForOnboarding()
        self.setupViews()
        self.pages = self.setupLabels()
    }
    
    private func setupTextForOnboarding() -> Void {
        self.titleText = ["Welcome To HabitHabit!", "Achieve Goals", "Features"]
        self.subtitleText = ["Hi \(self.databaseUsernameKey)! Thank you for downloading HabitHabit!", "Here at HabitHabit, we hope to help you achieve your goals and help you keep yourself accountable. Work hard and accomplish your goals!", "Add habits, track them with pictures, and add friends and help hold each other accountable!"]
    }
    
    private func setupViews() -> Void {
        self.view.backgroundColor = UIColor.habit.purple
        self.scrollView.delegate = self
        self.pageControl.addTarget(self,
                                   action: #selector(self.pageControlDidChange(_:)),
                                   for: .valueChanged)
        self.view.addSubview(self.scrollView)
        self.view.addSubview(self.pageControl)
    }
    
    private func setupLabels() -> [UIView] {
        var result: [UIView] = []
        for index in 0..<self.pageControl.numberOfPages {
            self.titleLabels[index].textColor = .white
            self.bodyLabels[index].textColor = .white
            self.titleLabels[index].font = UIFont(name: "Futura", size: 34)
            self.titleLabels[index].text = self.titleText[index]
            self.titleLabels[index].numberOfLines = 0
            self.bodyLabels[index].text = self.subtitleText[index]
            self.bodyLabels[index].numberOfLines = 0
            var subviews: [UIView] = [self.titleLabels[index], self.bodyLabels[index]]
            if index == 2 {
                self.segueButton = UIButton()
                self.segueButton?.backgroundColor = .black
                self.segueButton?.tintColor = UIColor.habit.orange
                self.segueButton?.setTitle("Go to app!", for: .normal)
                self.segueButton?.addTarget(self, action: #selector(self.goToLandingPage(_:)), for: .touchUpInside)
                subviews.append(self.segueButton!)
            }
            let stackView = UIStackView(arrangedSubviews: subviews)
            stackView.axis = .vertical
            stackView.spacing = 10
            result.append(stackView)
        }
        return result
    }
    
    @objc private func goToLandingPage(_ sender: Any) -> Void {
        let pulse = ButtonPulseAnimation(numberOfPulses: 1, radius: 200, position: self.view.center)
        pulse.animationDuration = 1.0
        pulse.backgroundColor = UIColor.habit.orange.cgColor
        self.view.layer.insertSublayer(pulse, below: self.view.layer)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.performSegue(withIdentifier: self.landingPageSegue, sender: nil)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.pageControl.frame = CGRect(x: 10, y: self.view.frame.size.height - 100, width: self.view.frame.size.width - 20, height: 70)
        self.scrollView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height - 100)
        if self.scrollView.subviews.count == 2 {
            self.configureScrollView()
        }
    }
    
    private func changeSubviewOnSwipe(previous: Int?, current: Int) -> Void {
        if previous != nil {
            let previousPage = self.pages[previous!]
            previousPage.removeFromSuperview()
        }
        let currentPage = self.pages[current]
        self.scrollView.addSubview(currentPage)
        currentPage.translatesAutoresizingMaskIntoConstraints = false
        currentPage.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        currentPage.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        currentPage.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -100).isActive = true
    }
    
    private func configureScrollView() {
        self.scrollView.contentSize = CGSize(width: self.view.frame.size.width * CGFloat(self.pageControl.numberOfPages), height: self.scrollView.frame.size.height)
        self.scrollView.isPagingEnabled = true
        self.changeSubviewOnSwipe(previous: nil, current: self.pageControl.currentPage)
    }
    
    @objc private func pageControlDidChange(_ sender: UIPageControl) {
        let current = sender.currentPage
        self.scrollView.setContentOffset(CGPoint(x: CGFloat(current) * self.view.frame.size.width, y: 0), animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let previousPage = self.pageControl.currentPage
        self.pageControl.currentPage = Int(floorf(Float(scrollView.contentOffset.x) / Float(scrollView.frame.size.width)))
        self.changeSubviewOnSwipe(previous: previousPage, current: self.pageControl.currentPage)
    }
    
}
