//
//  AnimationViewController.swift
//  HabitHabit
//
//  Created by Ishav Desai on 3/26/21.
//

import UIKit

class AnimationViewController: UIViewController {
    
    private var launchImageView: UIImageView = {
        let launchImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        launchImageView.image = UIImage(named: "Logo")
        return launchImageView
    }()
    private var mirrorLaunchImageView: UIImageView = {
        let mirrorLaunchImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        mirrorLaunchImageView.image = UIImage(named: "Logo")?.withHorizontallyFlippedOrientation()
        return mirrorLaunchImageView
    }()
    private let loginViewSegue: String = "ToLoginViewSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 119/255, green: 33/255, blue: 111/255, alpha: 1)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.launchImageView.center = view.center
        self.mirrorLaunchImageView.center = view.center
        // view.addSubview(self.launchImageView)
        view.addSubview(self.mirrorLaunchImageView)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
            self.animate()
        })
    }
    
    private func animate() -> Void {
        // insert animation here
        self.performSegue(withIdentifier: self.loginViewSegue, sender: nil)
    }
    
}
