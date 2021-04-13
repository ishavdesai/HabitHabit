//
//  ProfileSettingsViewController.swift
//  HabitHabit
//
//  Created by Ishav Desai on 4/4/21.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase

class ProfileSettingsViewController: UIViewController {
    
    @IBOutlet weak var profilePicture: UIImageView!
    private let storage = Storage.storage().reference()
    private let database: DatabaseReference = Database.database().reference()
    private let databaseUsernameKey: String = UserDefaults.standard.string(forKey: "kUsername") ?? "USERNAME_DATABASE_KEY_ERROR"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 119/255, green: 33/255, blue: 111/255, alpha: 1)
        self.setupPicture()
    }
    
    private func modifyImageSettings() -> Void {
        self.profilePicture.contentMode = .scaleAspectFill
        self.profilePicture.clipsToBounds = true
        self.profilePicture.layer.masksToBounds = true
        self.profilePicture.layer.cornerRadius = 150.0/2.0
    }
    
    private func setupPicture() -> Void {
        self.database.child(self.databaseUsernameKey).child("ProfilePictureURL").observeSingleEvent(of: .value) {
            snapshot in
            guard let urlString = snapshot.value as? String else {
                let image: UIImage = UIImage(named: "DefaultProfile")!
                self.profilePicture.image = image
                self.modifyImageSettings()
                return
            }
            guard let url = URL(string: urlString) else { return }
            let task = URLSession.shared.dataTask(with: url, completionHandler: {
                data, _, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async {
                    let image = UIImage(data: data)
                    self.profilePicture.image = image
                    self.modifyImageSettings()
                }
            })
            task.resume()
        }
    }
    
    @IBAction func changeProfilePicture(_ sender: Any) {
        let imagePicker: UIImagePickerController = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        let photoController: UIAlertController = UIAlertController(
            title: "Pick how to select picture.",
            message: "Choose if you would like to select a picture or from the photo library",
            preferredStyle: .actionSheet)
        let photoLibraryAction: UIAlertAction = UIAlertAction(
            title: "Photo Library",
            style: .default,
            handler: {_ in
                imagePicker.sourceType = .photoLibrary
                self.present(imagePicker, animated: true)
            })
        let takePhotoAction: UIAlertAction = UIAlertAction(
            title: "Take Photo",
            style: .default,
            handler: {_ in
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true)
            })
        photoController.addAction(photoLibraryAction)
        photoController.addAction(takePhotoAction)
        present(photoController, animated: true, completion: nil)
    }
    
}

extension ProfileSettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private func setupAndStoreSelectedImage(image: UIImage) {
        self.profilePicture.image = image
        self.modifyImageSettings()
        guard let imageData = image.pngData() else { return }
        self.storage.child(self.databaseUsernameKey).child("ProfilePhoto.png").putData(imageData, metadata: nil, completion: { _, error in
            guard error ==  nil else { print("Failed to upload"); return }
            self.storage.child(self.databaseUsernameKey).child("ProfilePhoto.png").downloadURL(completion: {
                url, error in
                guard let url = url, error == nil else { return }
                let urlString = url.absoluteString
                self.database.child(self.databaseUsernameKey).child("ProfilePictureURL").setValue(urlString)
                print(urlString)
            })
        })
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage else { return }
        self.setupAndStoreSelectedImage(image: image)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
