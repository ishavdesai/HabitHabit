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
        self.view.backgroundColor = UIColor.habit.purple
        self.launchImageView.center = view.center
        self.mirrorLaunchImageView.center = view.center
        view.addSubview(self.launchImageView)
        view.addSubview(self.mirrorLaunchImageView)
        self.mirrorLaunchImageView.alpha = 0
        self.animate()
    }
    
    private func animate() -> Void {
        // insert animation here
        UIView.animate(
            withDuration: 1.0,
            delay: 0.0,
            options: .curveEaseOut,
            animations: {
                self.launchImageView.alpha = 0
            },
            completion: {
                finished in
                if finished {
                    UIView.animate(
                        withDuration: 1.0,
                        delay: 0.0,
                        options: .curveEaseIn,
                        animations: {
                            self.mirrorLaunchImageView.alpha = 1
                        },
                        completion: {
                            finished in
                            if finished {
                                usleep(1694200)
                                self.performSegue(withIdentifier: self.loginViewSegue, sender: nil)
                            }
                        })
                }
            })
    }
    
}
