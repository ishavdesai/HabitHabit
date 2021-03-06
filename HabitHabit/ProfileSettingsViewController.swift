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
    @IBOutlet weak var changePFPButton: UIButton!
    private let storage = Storage.storage().reference()
    private let database: DatabaseReference = Database.database().reference()
    private let databaseUsernameKey: String = UserDefaults.standard.string(forKey: "kUsername") ?? "USERNAME_DATABASE_KEY_ERROR"
    @IBOutlet weak var toggle: UISwitch!
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.habit.purple
        self.setupPicture()
        UIDesign.cleanupButton(button: self.changePFPButton)
        self.usernameLabel.text = "username: \(self.databaseUsernameKey)"
        self.initializeToggle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupPicture()
    }
    
    private func modifyImageSettings() -> Void {
        self.profilePicture.contentMode = .scaleAspectFill
        self.profilePicture.clipsToBounds = true
        self.profilePicture.layer.masksToBounds = true
        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.height/2
        //self.profilePicture.layer.cornerRadius = 150.0/2.0
    }
    
    private func setupPicture() -> Void {
        let image: UIImage = UtilityClass.profilePicture
        self.profilePicture.image = image
        self.modifyImageSettings()
    }
    
    private func displaySourceTypeErrorMessage(message: String) -> Void {
        let controller: UIAlertController = UIAlertController(
            title: "Source Type not Available",
            message: message,
            preferredStyle: .alert)
        controller.addAction(UIAlertAction(
                                title: "OK",
                                style: .default,
                                handler: nil))
        present(controller, animated: true, completion: nil)
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
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                    imagePicker.sourceType = .photoLibrary
                    self.present(imagePicker, animated: true)
                } else {
                    self.displaySourceTypeErrorMessage(message: "Unable to open Photo Library. Please check permissions.")
                }
            })
        let takePhotoAction: UIAlertAction = UIAlertAction(
            title: "Take Photo",
            style: .default,
            handler: {_ in
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    imagePicker.sourceType = .camera
                    self.present(imagePicker, animated: true)
                } else {
                    self.displaySourceTypeErrorMessage(message: "Unable to access camera. Please check permissions. If using a simulator, you can't access the camera.")
                }
            })
        photoController.addAction(photoLibraryAction)
        photoController.addAction(takePhotoAction)
        present(photoController, animated: true, completion: nil)
    }
    
    private func initializeToggle() {
        self.toggle.layer.cornerRadius = 16

        
        self.database.child(self.databaseUsernameKey).child("Private").getData{ (error, snapshot) in
            if let error = error {
                print("Error getting data \(error)")
            }
            else if snapshot.exists() {
                let isOn = snapshot.value as? Bool ?? false
                print(isOn)
                if (isOn) {
                    DispatchQueue.main.async {
                        self.toggle.isOn = true
                    }
                } else {
                    DispatchQueue.main.async {
                        self.toggle.isOn = false
                    }
                }
            }
            else {
                DispatchQueue.main.async {
                    self.toggle.isOn = false
                }
            }
        }
    }
    
    @IBAction func onToggle(_ sender: Any) {
        if toggle.isOn {
            UtilityClass.accountIsPrivate = true
            self.database.child(self.databaseUsernameKey).child("Private").setValue(true)
        } else {
            UtilityClass.accountIsPrivate = false
            self.database.child(self.databaseUsernameKey).child("Private").setValue(false)
        }
    }
    
}

extension ProfileSettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private func setupAndStoreSelectedImage(image: UIImage) {
        self.profilePicture.image = image
        self.modifyImageSettings()
        guard let imageData = image.jpegData(compressionQuality: UtilityClass.compressionRate) else { return }
        self.storage.child(self.databaseUsernameKey).child("ProfilePhoto.png").putData(imageData, metadata: nil, completion: { _, error in
            guard error ==  nil else { print("Failed to upload"); return }
            self.storage.child(self.databaseUsernameKey).child("ProfilePhoto.png").downloadURL(completion: {
                url, error in
                guard let url = url, error == nil else { return }
                let urlString = url.absoluteString
                self.database.child(self.databaseUsernameKey).child("ProfilePictureURL").setValue(urlString)
            })
        })
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage else { return }
        UtilityClass.profilePicture = image
        self.setupAndStoreSelectedImage(image: image)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
