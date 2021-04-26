//
//  FriendRequestTableViewCell.swift
//  HabitHabit
//
//  Created by Ishav Desai on 4/26/21.
//

import UIKit
import FirebaseDatabase

class FriendRequestTableViewCell: UITableViewCell {

    @IBOutlet weak var friendProfilePicture: UIImageView!
    @IBOutlet weak var username: UILabel!
    var index: Int!
    var delegate: DeleteFriendRequestFromTableDelegate!
    private let databaseUsernameKey: String = UserDefaults.standard.string(forKey: "kUsername") ?? "USERNAME_DATABASE_KEY_ERROR"
    private let database: DatabaseReference = Database.database().reference()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = UIColor(red: 119/255, green: 33/255, blue: 111/255, alpha: 1)
    }
    
    private func removeFriendRequestFromDatabase() -> Void {
        self.database.child(self.databaseUsernameKey).child("Friend-Requests").observeSingleEvent(of: .value) {
            snapshot in
            for case let child as DataSnapshot in snapshot.children {
                guard let value = child.value as? String else { return }
                if value == self.username.text {
                    self.database.child(self.databaseUsernameKey).child("Friend-Requests").child(child.key).removeValue()
                }
            }
        }
        self.database.child(self.username.text!).child("FriendRequestsSent").observeSingleEvent(of: .value) {
            snapshot in
            for case let child as DataSnapshot in snapshot.children {
                guard let value = child.value as? String else { return }
                if value == self.databaseUsernameKey {
                    self.database.child(self.username.text!).child("FriendRequestsSent").child(child.key).removeValue()
                }
            }
        }
    }
    
    private func addFriend() -> Void {
        self.database.child(self.databaseUsernameKey).child("Friends").child(String(Int.random(in: 0..<1_000_000))).setValue(self.username!.text!)
        self.database.child(self.username!.text!).child("Friends").child(String(Int.random(in: 0..<1_000_000))).setValue(self.databaseUsernameKey)
    }
    
    @IBAction func acceptRequest(_ sender: Any) {
        self.delegate.deleteFriendRequestFromTable(index: self.index)
        self.addFriend()
        self.removeFriendRequestFromDatabase()
    }
    
    @IBAction func denyRequest(_ sender: Any) {
        self.delegate.deleteFriendRequestFromTable(index: self.index)
        self.removeFriendRequestFromDatabase()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
