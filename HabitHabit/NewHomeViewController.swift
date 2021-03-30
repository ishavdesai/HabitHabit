//
//  NewHomeViewController.swift
//  HabitHabit
//
//  Created by Shreyas Amargol on 3/30/21.
//

import UIKit

class NewHomeViewController: UIViewController {
    
    @IBOutlet weak var habitTableView: UITableView!
    
    public var habitsList: [Habit] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        habitTableView.delegate = self
        habitTableView.dataSource = self
                
        self.tabBarItem.title = "New Home"
        navigationController?.navigationBar.prefersLargeTitles = true
//        navigationItem.largeTitleDisplayMode = .never
        
        let now = Date()
        let df = DateFormatter()
        df.dateFormat = "LLLL dd, yyyy"
        navigationItem.title = df.string(from: now)
        
        habitsList.append(Habit(habit: "Wake Up Early", streak: 3, dates: []))
        habitsList.append(Habit(habit: "Go for a run", streak: 1, dates: []))
        habitsList.append(Habit(habit: "Jerk it", streak: 8, dates: []))
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

extension NewHomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return habitsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let habit = habitsList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HabitCell") as! HabitTableViewCell
        
        cell.setProperties(name: habit.habit, streak: habit.streak)
        
        return cell
    }
}
