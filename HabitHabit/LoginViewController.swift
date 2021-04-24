//
//  ViewController.swift
//  HabitHabit
//
//  Created by Ishav Desai on 3/26/21.
//

import UIKit
import Firebase
import GoogleSignIn
import FirebaseDatabase

class LoginViewController: UIViewController, GIDSignInDelegate {
    
    private var onLoginSegment: Bool = true
    private let loginSuccessSegue: String = "LoginSuccessSegue"
    private let database: DatabaseReference = Database.database().reference()
    
    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var loginSegment: UISegmentedControl!
    @IBOutlet weak var signInUpButton: UIButton!
    @IBOutlet weak var loginStatus: UILabel!
    @IBOutlet weak var stackView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupGoogleLogin()
        self.setupCustomUsernamePassword()
        self.setupViewUI()
    }
    
    private func setupGoogleLogin() -> Void {
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.clientID = "789038255534-q4goruaca6g9813aroqqgugfeq6cd0ug.apps.googleusercontent.com"
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                self.loginAttempt(success: false, errorMessage: "The user has not signed in before or they have since signed out.", usernameKey: nil, username: nil)
            } else {
                self.loginAttempt(success: false, errorMessage: error.localizedDescription, usernameKey: nil, username: nil)
            }
            return
        }
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error, authResult == nil {
                self.loginAttempt(success: false, errorMessage: error.localizedDescription, usernameKey: nil, username: nil)
            } else {
                let userID: String = user.userID
                let username: String = user.profile.givenName + user.profile.familyName
                self.loginAttempt(success: true, errorMessage: nil, usernameKey: userID, username: username)
            }
        }
    }
    
    private func setupCustomUsernamePassword() -> Void {
        self.usernameField?.placeholder = "Username"
        self.usernameField?.autocorrectionType = .no
        self.passwordField?.placeholder = "Password"
        self.passwordField?.isSecureTextEntry = true
        self.passwordField?.autocorrectionType = .no
        self.confirmPasswordField?.placeholder = "Confirm Password"
        if self.onLoginSegment {
            self.confirmPasswordField?.isHidden = true
            self.signInUpButton?.setTitle(UIDesign.adjustText(text: "Sign In"), for: .normal)
        }
        self.loginStatus?.text = ""
        self.loginStatus?.textColor = .red
    }
    
    @IBAction func changeLoginView(_ sender: Any) {
        self.loginStatus?.text = ""
        switch self.loginSegment.selectedSegmentIndex {
        case 0:
            self.onLoginSegment = true
            self.confirmPasswordField.isHidden = true
            //self.signInUpButton?.setTitle("Sign In", for: .normal)
            self.signInUpButton?.setTitle(UIDesign.adjustText(text: "Sign In"), for: .normal)

        case 1:
            self.onLoginSegment = false
            self.confirmPasswordField.isHidden = false
            self.signInUpButton?.setTitle(UIDesign.adjustText(text: "Sign Up"), for: .normal)
        default: break
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func checkFieldAccuracy() -> Bool {
        if self.usernameField?.text == "" {
            self.loginStatus?.text = "Login Failed: No Username Entered"
            return false
        } else if self.passwordField?.text == "" {
            self.loginStatus?.text = "Login Failed: No Password Entered"
            return false
        } else if !self.onLoginSegment && self.confirmPasswordField?.text == "" {
            self.loginStatus?.text = "Sign Up Failed: Please confirm your password"
            return false
        } else if !self.onLoginSegment && self.confirmPasswordField?.text != self.passwordField?.text {
            self.loginStatus?.text = "Sign Up Failed: Please ensure the Password matches the Confirmed Password"
            return false
        }
        return true
    }
    
    private func loginAttempt(success: Bool, errorMessage: String?, usernameKey: String?, username: String?) -> Void {
        if !success {
            self.loginStatus?.text = "Sign In Failed: \(errorMessage!)"
        } else {
            let defaults: UserDefaults = UserDefaults.standard
            self.loginStatus?.text = "Login Success"
            defaults.setValue(usernameKey!, forKey: "kUsernameDatabaseKey")
            defaults.setValue(username!, forKey: "kUsername")
            
            performSegue(withIdentifier: self.loginSuccessSegue, sender: nil)
        }
    }
    
    private func handleSignIn() -> Void {
        guard let username = self.usernameField?.text,
              let password = self.passwordField?.text,
              username.count > 0,
              password.count > 0 else { return }
        Auth.auth().signIn(withEmail: username + "@habithabit.com", password: password) {
            user, error in
            if let error = error, user == nil {
                self.loginAttempt(success: false, errorMessage: error.localizedDescription, usernameKey: nil, username: nil)
            } else {
                self.loginAttempt(success: true, errorMessage: nil, usernameKey: username, username: username)
            }
        }
    }
    
    private func handleSignUp() -> Void {
        guard let username = self.usernameField?.text,
              let password = self.passwordField?.text,
              let confirmPassword = self.confirmPasswordField?.text,
              username.count > 0,
              password.count > 0,
              confirmPassword.count > 0,
              password == confirmPassword,
              !(username.contains(".") || username.contains("#") || username.contains("$") || username.contains("[") || username.contains("]")) else { self.loginStatus.text = "Error in sign up information. Note: Username can't contain a ., #, $, [, or ] characters."; return }
        Auth.auth().createUser(withEmail: username + "@habithabit.com", password: password) {
            user, error in
            if error == nil {
                Auth.auth().signIn(withEmail: username + "@habithabit.com", password: password) {
                    user, error in
                    if let error = error, user == nil {
                        self.loginAttempt(success: false, errorMessage: error.localizedDescription, usernameKey: nil, username: nil)
                    } else {
                        self.loginAttempt(success: true, errorMessage: nil, usernameKey: username, username: username)
                    }
                }
            } else if let error = error, user == nil {
                self.loginAttempt(success: false, errorMessage: error.localizedDescription, usernameKey: nil, username: nil)
            }
        }
    }
    
    @IBAction func signInUpButtonPressed(_ sender: Any) {
        if self.checkFieldAccuracy() {
            self.onLoginSegment ? self.handleSignIn() : self.handleSignUp()
        }
    }
    
    private func setupViewUI() -> Void {
        self.view.backgroundColor = UIColor(red: 119/255, green: 33/255, blue: 111/255, alpha: 1)
        self.googleSignInButton.colorScheme = GIDSignInButtonColorScheme(rawValue: 0)!
        self.stackView.backgroundColor = UIColor(red: 119/255, green: 33/255, blue: 111/255, alpha: 1)
        
        UIDesign.cleanupButton(button: self.signInUpButton, dontAdjustText: true)
    }
    
}
