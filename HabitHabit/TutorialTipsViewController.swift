//
//  TutorialTipsViewController.swift
//  HabitHabit
//
//  Created by Ally on 5/4/21.
//

import UIKit

class TutorialTipsViewController: UIViewController {

    private var titleText: String = ""
    private var subtitleText: String = ""
    private var button: UIButton?
    
    private let loginContentView:UIView = {
      let view = UIView()
      view.translatesAutoresizingMaskIntoConstraints = false
      return view
    }()
    
    private let titleLabel:UILabel = {
        let txtField = UILabel()
        txtField.textColor = .white
        txtField.translatesAutoresizingMaskIntoConstraints = false
        txtField.font = UIFont(name: "Futura", size: 28)
        txtField.numberOfLines = 0
        txtField.textAlignment = .center
        return txtField
    }()
    
    private let subtitleLabel:UILabel = {
        let txtField = UILabel()
        txtField.translatesAutoresizingMaskIntoConstraints = false
        txtField.textColor = .white
        txtField.numberOfLines = 0
        txtField.textAlignment = .center
        return txtField
    }()
    
    convenience init(titleText:String, subtitleText:String, button:UIButton?) {
        self.init(nibName:nil, bundle:nil)
        self.titleText = titleText
        self.subtitleText = subtitleText
        if(button != nil) {
            print ("Hey, we have a buton!")
        }
        self.button = button
    }
    
    
    func setupLayout() {
        
        loginContentView.leftAnchor.constraint(equalTo:view.leftAnchor).isActive = true
        loginContentView.rightAnchor.constraint(equalTo:view.rightAnchor).isActive = true
        loginContentView.heightAnchor.constraint(equalToConstant: view.frame.height/3).isActive = true
        loginContentView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        titleLabel.topAnchor.constraint(equalTo:loginContentView.topAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo:loginContentView.topAnchor, constant:40).isActive = true
        titleLabel.leftAnchor.constraint(equalTo:loginContentView.leftAnchor).isActive = true
        titleLabel.rightAnchor.constraint(equalTo:loginContentView.rightAnchor).isActive = true
        titleLabel.leftAnchor.constraint(equalTo:loginContentView.leftAnchor, constant:20).isActive = true
        titleLabel.rightAnchor.constraint(equalTo:loginContentView.rightAnchor, constant:-20).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant:50).isActive = true
        
        subtitleLabel.leftAnchor.constraint(equalTo:loginContentView.leftAnchor, constant:20).isActive = true
        subtitleLabel.rightAnchor.constraint(equalTo:loginContentView.rightAnchor, constant:-20).isActive = true
        subtitleLabel.heightAnchor.constraint(equalToConstant:100).isActive = true
        subtitleLabel.topAnchor.constraint(equalTo:titleLabel.bottomAnchor, constant:20).isActive = true
        
        if(button != nil) {
            button!.topAnchor.constraint(equalTo:subtitleLabel.bottomAnchor, constant:20).isActive = true
            button!.leftAnchor.constraint(equalTo:loginContentView.leftAnchor, constant:20).isActive = true
            button!.rightAnchor.constraint(equalTo:loginContentView.rightAnchor, constant:-20).isActive = true
            button!.heightAnchor.constraint(equalToConstant:50).isActive = true
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.habit.purple
        
        titleLabel.text = titleText
        subtitleLabel.text = subtitleText
                
        loginContentView.addSubview(titleLabel)
        loginContentView.addSubview(subtitleLabel)
        print("RUIRUI button check:")
        if(button != nil) {
            print("Button!")
            loginContentView.addSubview(button!)
        } else {
            print("No button found :////")
            loginContentView.addSubview(button!)
        }
        view.addSubview(loginContentView)
        
        setupLayout()

    }

}
