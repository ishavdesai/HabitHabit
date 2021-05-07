//
//  OnboardingPFPViewController.swift
//  HabitHabit
//
//  Created by Ally on 5/5/21.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase

class OnboardingPFPViewController: UIViewController {

    @IBOutlet weak var changePFPButton: UIButton!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    private let storage = Storage.storage().reference()
    private let database: DatabaseReference = Database.database().reference()
    private let databaseUsernameKey: String = UserDefaults.standard.string(forKey: "kUsername") ?? "USERNAME_DATABASE_KEY_ERROR"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.habit.purple
        self.setupPicture()
        UIDesign.cleanupButton(button: self.changePFPButton)
        self.messageLabel.text = "Start by adding a profile picture."
        self.messageLabel.textColor = .white
        self.messageLabel.numberOfLines = 0
        self.messageLabel.textAlignment = .center
        self.messageLabel.font = UIFont(name: "Futura", size: 20)
        
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension OnboardingPFPViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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

