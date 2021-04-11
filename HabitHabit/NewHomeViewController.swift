//
//  NewHomeViewController.swift
//  HabitHabit
//
//  Created by Shreyas Amargol on 3/30/21.
//

import UIKit
import FirebaseDatabase


class NewHomeViewController: UIViewController {
    
    @IBOutlet weak var habitTableView: UITableView!
    
    public var habitsList: [Habit] = []
    
    private let database: DatabaseReference = Database.database().reference()
    private let databaseUsernameKey: String = UserDefaults.standard.string(forKey: "kUsernameDatabaseKey") ?? "USERNAME_DATABASE_KEY_ERROR"
    

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
//
//        habitsList.append(Habit(habit: "Wake Up Early", streak: 3, dates: []))
//        habitsList.append(Habit(habit: "Go for a run", streak: 1, dates: []))
        
        
        self.database.child(self.databaseUsernameKey).child("Habit").observe(DataEventType.value) {
            snapshot in
            
            var list = [Habit]()

            for case let child as DataSnapshot in snapshot.children {

                guard let value = child.value as? [String: String] else {
                    return
                }

                let (habitExists, habit): (Bool, Habit?) = self.makeHabit(value: value)

                if habitExists {
                    list.append(habit!)
                }
            }
            
            self.habitsList = list
            self.habitTableView.reloadData()
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


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func onPressPlus(_ sender: Any) {
        let storyboard = UIStoryboard(name:"Main", bundle:nil)
        let habitManagerView = storyboard.instantiateViewController(withIdentifier: "HabitSettingsVCID")
        self.present(habitManagerView, animated:true, completion:nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "habitPressSegue",
           let nextVC = segue.destination as? DetailedHabitViewController {
            let row = sender as! Int
            
            nextVC.habit = habitsList[row]
        }

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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let cell = tableView.cellForRow(at: indexPath as IndexPath)
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        performSegue(withIdentifier: "habitPressSegue", sender: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            habitsList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
}
