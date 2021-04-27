//
//  FriendRequestsViewController.swift
//  HabitHabit
//
//  Created by Ishav Desai on 4/26/21.
//

import UIKit
import FirebaseDatabase

protocol DeleteFriendRequestFromTableDelegate {
    func deleteFriendRequestFromTable(index: Int) -> Void
}

class FriendRequestsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DeleteFriendRequestFromTableDelegate {
    
    @IBOutlet weak var friendRequestsTableView: UITableView!
    @IBOutlet weak var profilePicture: UIImageView!
    private var friendRequestUsernames: [String] = []
    private var friendProfilePicDict: [String: UIImage] = [:]
    private let friendRequestCell: String = "FriendRequestCell"
    private let databaseUsernameKey: String = UserDefaults.standard.string(forKey: "kUsername") ?? "USERNAME_DATABASE_KEY_ERROR"
    private let database: DatabaseReference = Database.database().reference()
    private let refreshControl = UIRefreshControl()
    private let group = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Friend Requests"
        self.view.backgroundColor = UIColor.habit.purple
        self.friendRequestsTableView.delegate = self
        self.friendRequestsTableView.dataSource = self
        self.setupRefreshControl()
        self.setupPicture()
        self.loadFriendRequests()
    }
    
    private func setupRefreshControl() -> Void {
        self.refreshControl.addTarget(self, action: #selector(self.refreshFriendRequests(_:)), for: .valueChanged)
        self.refreshControl.tintColor = .white
        self.refreshControl.attributedTitle = NSAttributedString(string: "Fetching Friend Requests ...")
        self.friendRequestsTableView.refreshControl = self.refreshControl
    }
    
    @objc private func refreshFriendRequests(_ sender: Any) {
        self.loadFriendRequests()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friendRequestUsernames.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.friendRequestsTableView.dequeueReusableCell(withIdentifier: self.friendRequestCell, for: indexPath as IndexPath) as! FriendRequestTableViewCell
        let friendName: String = self.friendRequestUsernames[indexPath.row]
        cell.username?.text = friendName
        cell.friendProfilePicture?.image = self.friendProfilePicDict[friendName]
        self.modifyImageSettings(imageView: cell.friendProfilePicture, imageSize: 75.0)
        UIDesign.setCellProperties(cell: cell)
        cell.index = indexPath.row
        cell.delegate = self
        return cell
    }
    
    private func getFriendProfilePicture(friendName: String) -> Void {
        self.group.enter()
        let result = UIImage(named: "DefaultProfile")!
        self.database.child(friendName).child("ProfilePictureURL").observeSingleEvent(of: .value) {
            snapshot in
            if snapshot.exists() {
                let urlString: String = snapshot.value as! String
                guard let url = URL(string: urlString) else {
                    self.friendProfilePicDict[friendName] = result
                    self.group.leave()
                    return
                }
                let task = URLSession.shared.dataTask(with: url, completionHandler: {
                    data, _, error in
                    guard let data = data, error == nil else {
                        self.friendProfilePicDict[friendName] = result
                        self.group.leave()
                        return
                    }
                    DispatchQueue.main.async {
                        let image: UIImage = UIImage(data: data)!
                        self.friendProfilePicDict[friendName] = image
                        self.group.leave()
                    }
                })
                task.resume()
            } else {
                self.friendProfilePicDict[friendName] = result
                self.group.leave()
            }
        }
    }
    
    private func modifyImageSettings(imageView: UIImageView, imageSize: CGFloat) -> Void {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageSize / 2.0
    }
    
    private func setupPicture() -> Void {
        self.database.child(self.databaseUsernameKey).child("ProfilePictureURL").observeSingleEvent(of: .value) {
            snapshot in
            guard let urlString = snapshot.value as? String else {
                let image: UIImage = UIImage(named: "DefaultProfile")!
                self.profilePicture.image = image
                self.modifyImageSettings(imageView: self.profilePicture, imageSize: 150.0)
                return
            }
            guard let url = URL(string: urlString) else { return }
            let task = URLSession.shared.dataTask(with: url, completionHandler: {
                data, _, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async {
                    let image = UIImage(data: data)
                    self.profilePicture.image = image
                    self.modifyImageSettings(imageView: self.profilePicture, imageSize: 150.0)
                }
            })
            task.resume()
        }
    }
    
    private func loadFriendRequests() -> Void {
        self.database.child(self.databaseUsernameKey).child("Friend-Requests").observeSingleEvent(of: .value) {
            snapshot in
            var tempFriendRequests: [String] = []
            for case let child as DataSnapshot in snapshot.children {
                guard let value = child.value as? String else { return }
                tempFriendRequests.append(value)
                self.getFriendProfilePicture(friendName: value)
            }
            self.group.notify(queue: .main) {
                self.friendRequestUsernames = tempFriendRequests
                self.friendRequestsTableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.friendRequestsTableView.deselectRow(at: indexPath, animated: true)
    }
    
    func deleteFriendRequestFromTable(index: Int) {
        self.friendRequestUsernames.remove(at: index)
        self.friendRequestsTableView.reloadData()
    }

}
