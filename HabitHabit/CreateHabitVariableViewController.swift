//
//  CreateHabitVariableViewController.swift
//  HabitHabit
//
//  Created by Ally on 4/4/21.
//

import UIKit

class CreateHabitVariableViewController: UIViewController {

    var habitText:String = "Try adding more habits."
    
    convenience init() {
        self.init(nibName:nil, bundle:nil)
    }
    
    private let loginContentView:UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let updateBtn:UIButton = {
        let btn = UIButton(type:.system)
        btn.backgroundColor = .systemBlue
        btn.setTitle("Manage Habits", for: .normal)
        btn.tintColor = .white
        btn.layer.cornerRadius = 5
        btn.clipsToBounds = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(createHabitButtonPress), for: .allTouchEvents)
        return btn
    }()
    
    @objc func createHabitButtonPress() {
        let storyboard = UIStoryboard(name:"Main", bundle:nil)
        let habitManagerView = storyboard.instantiateViewController(withIdentifier: "HabitSettingsVCID")
        self.present(habitManagerView, animated:true, completion:nil)
    }
    
    private let headerLabel:UILabel = {
        let header = UILabel()
        header.text = ""
        header.translatesAutoresizingMaskIntoConstraints = false
        header.font = UIFont(name:"GillSans", size: 25.0)
        header.textColor = .black
        return header
    }()
    
    private let streakLabel:UILabel = {
        let streak = UILabel()
        streak.text = ""
        streak.font = UIFont(name:"GillSans", size: 45.0)
        streak.translatesAutoresizingMaskIntoConstraints = false
        return streak
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        loginContentView.addSubview(headerLabel)
        headerLabel.text = self.habitText
        loginContentView.addSubview(streakLabel)
        loginContentView.addSubview(updateBtn)
        view.addSubview(loginContentView)

        loginContentView.leftAnchor.constraint(equalTo:view.leftAnchor).isActive = true
        loginContentView.rightAnchor.constraint(equalTo:view.rightAnchor).isActive = true
        loginContentView.heightAnchor.constraint(equalToConstant: view.frame.height/3).isActive = true
        loginContentView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        headerLabel.topAnchor.constraint(equalTo:loginContentView.topAnchor).isActive = true
        headerLabel.topAnchor.constraint(equalTo:loginContentView.topAnchor, constant:40).isActive = true
        headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        //streakLabel.leftAnchor.constraint(equalTo:loginContentView.leftAnchor, constant:20).isActive = true
        //streakLabel.rightAnchor.constraint(equalTo:loginContentView.rightAnchor, constant:-20).isActive = true
        streakLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        streakLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        streakLabel.topAnchor.constraint(equalTo:headerLabel.bottomAnchor, constant:20).isActive = true
        

        updateBtn.topAnchor.constraint(equalTo:streakLabel.bottomAnchor, constant:55).isActive = true
        updateBtn.leftAnchor.constraint(equalTo:loginContentView.leftAnchor, constant:20).isActive = true
        updateBtn.rightAnchor.constraint(equalTo:loginContentView.rightAnchor, constant:-20).isActive = true
        updateBtn.heightAnchor.constraint(equalToConstant:50).isActive = true
        

        // label
        let labelInst = UILabel()
        self.view.addSubview(labelInst)
        labelInst.textColor = .black
        labelInst.translatesAutoresizingMaskIntoConstraints = false
        labelInst.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 50).isActive = true
        labelInst.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20).isActive = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //self.tabBarItem.image = UIImage(named: "item")
    //self.tabBarItem.selectedImage = UIImage(named: "item_selected")
    // Do any additional setup after loading the view.
}
