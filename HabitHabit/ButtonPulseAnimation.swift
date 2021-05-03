//
//  ButtonPulseAnimation.swift
//  HabitHabit
//
//  Created by Ishav Desai on 5/3/21.
//
// Source: https://www.youtube.com/watch?v=SasWhHe1ZtM&ab_channel=LetCreateAnApp

import UIKit

class ButtonPulseAnimation: CALayer {

    var animationGroup: CAAnimationGroup = CAAnimationGroup()
    var animationDuration: TimeInterval = 1.5
    var radius: CGFloat = 200
    var numberOfPulses: Float = 10
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(numberOfPulses: Float = 10, radius: CGFloat = 200, position: CGPoint) {
        super.init()
        self.numberOfPulses = numberOfPulses
        self.backgroundColor = UIColor.habit.orange.cgColor
        self.contentsScale = UIScreen.main.scale
        self.opacity = 0
        self.radius = radius
        self.position = position
        self.bounds = CGRect(x: 0, y: 0, width: self.radius * 2, height: self.radius * 2)
        self.cornerRadius = self.radius
        DispatchQueue.global(qos: .default).async {
            self.setupAnimationGroup()
            DispatchQueue.main.async {
                self.add(self.animationGroup, forKey: "pulse")
            }
        }
    }
    
    func scaleAnimation() -> CABasicAnimation {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale.xy")
        scaleAnimation.fromValue = NSNumber(value: 0)
        scaleAnimation.toValue = NSNumber(value: 1)
        scaleAnimation.duration = self.animationDuration
        return scaleAnimation
    }
    
    func createOpacityAnimation() -> CAKeyframeAnimation {
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimation.duration = self.animationDuration
        opacityAnimation.keyTimes = [0, 0.3, 1]
        opacityAnimation.values = [0.4, 0.8, 0]
        return opacityAnimation
    }
    
    func setupAnimationGroup() -> Void {
        self.animationGroup.duration = self.animationDuration
        self.animationGroup.repeatCount = self.numberOfPulses
        let defaultCurve = CAMediaTimingFunction(name: .default)
        self.animationGroup.timingFunction = defaultCurve
        self.animationGroup.animations = [self.scaleAnimation(), self.createOpacityAnimation()]
    }
    
}
