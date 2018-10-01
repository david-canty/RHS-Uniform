//
//  RegisterViewController.swift
//  RHS Uniform
//
//  Created by David Canty on 14/03/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {

    var hidePassword = true
    var feedbackGenerator: UINotificationFeedbackGenerator?
    
    @IBOutlet weak var stackViewCenterYConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nameValidationLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailValidationLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordValidationLabel: UILabel!
    
    @IBOutlet weak var showPasswordButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShowNotification(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHideNotification(notification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        hideActivityIndicator()
        enableInput()
        nameValidationLabel.isHidden = true
        emailValidationLabel.isHidden = true
        passwordValidationLabel.isHidden = true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func showActivityIndicator() {
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideActivityIndicator() {
        
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    func disableInput() {
        
        nameTextField.isUserInteractionEnabled = false
        emailTextField.isUserInteractionEnabled = false
        passwordTextField.isUserInteractionEnabled = false
        showPasswordButton.isUserInteractionEnabled = false
        registerButton.isUserInteractionEnabled = false
        signInButton.isUserInteractionEnabled = false
    }
    
    func enableInput() {
        
        nameTextField.isUserInteractionEnabled = true
        emailTextField.isUserInteractionEnabled = true
        passwordTextField.isUserInteractionEnabled = true
        showPasswordButton.isUserInteractionEnabled = true
        registerButton.isUserInteractionEnabled = true
        signInButton.isUserInteractionEnabled = true
    }
    
    @objc func keyboardShowNotification(notification: NSNotification) {
        
        self.stackViewCenterYConstraint.constant = -100.0
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func keyboardHideNotification(notification: NSNotification) {
        
        self.stackViewCenterYConstraint.constant = 0.0
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.view.layoutIfNeeded()
        })
    }
    
    // MARK: - Button Actions

    @IBAction func showPasswordTapped(_ sender: UIButton) {
        
        hidePassword = !hidePassword
        passwordTextField.isSecureTextEntry = hidePassword
        
        let showPasswordButtonTitle = hidePassword ? "Show Password" : "Hide Password"
        showPasswordButton.setTitle(showPasswordButtonTitle, for: .normal)
    }
    
    @IBAction func registerTapped(_ sender: UIButton) {
        
        disableInput()
        
        if !validateFields() {
            
            prepareFeedback()
            
            enableInput()
            
            triggerErrorFeedback()
            
            return
        }
        
        showActivityIndicator()
        
        let name = nameTextField.text!
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        registerUserWith(name: name, email: email, password: password)
    }
    
    func registerUserWith(name: String, email: String, password: String) {
        
        let firebaseAuth = Auth.auth()
        
        firebaseAuth.createUser(withEmail: email, password: password) { (authDataResult, error) in
            
            if let error = error as NSError? {
                
                self.prepareFeedback()
                
                if let errorCode = AuthErrorCode(rawValue: error.code) {
                    
                    switch errorCode {
                        
                    case .invalidEmail:
                        self.displayAlert(withTitle: "Invalid Email", message: "The email you entered is invalid.")
                        
                    case .emailAlreadyInUse:
                        self.displayAlert(withTitle: "Email In Use", message: "The email you enetered is already in use.")
                        
                    case .weakPassword:
                        self.displayAlert(withTitle: "Weak Password", message: "The password you enetered is too weak.")
                        
                    case .networkError:
                        self.displayAlert(withTitle: "Network Error", message: "Please check that your device is connected to Wi-Fi or has a mobile data connection.")
                        
                    default:
                        self.displayAlert(withTitle: "Error Registering", message: "You account could not be registred: \(error.localizedDescription)")
                    }
                }
                
                self.triggerErrorFeedback()
                
                self.hideActivityIndicator()
                self.enableInput()
                
            } else {
                
                if let authData = authDataResult {
                    
                    self.save(name: name, forUser: authData.user)
                    self.sendVerificationEmail(toUser: authData.user)
                
                    KeychainController.saveIdToken()
                    KeychainController.save(email: email, password: password)
                    self.hideActivityIndicator()
                    
                    let alertTitle = "Registration Successful"
                    let alertMesage = "Your account has been successfully registered. You will receive an email asking you to verify your email address.\n\nYou can now sign in with your registered email address and password."
                    
                    let alertController = UIAlertController(title: alertTitle, message: alertMesage, preferredStyle: .alert)
                    
                    alertController.view.tintColor = UIColor(red: 203.0/255.0, green: 8.0/255.0, blue: 19.0/255.0, alpha: 1.0)
                    
                    let alertAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        
                        do {
                            
                            try firebaseAuth.signOut()
                            
                            DispatchQueue.main.async {
                                self.navigationController?.popViewController(animated: true)
                            }
                            
                        } catch let signOutError as NSError {
                            
                            print ("Error signing out: %@", signOutError)
                        }
                    })
                    
                    alertController.addAction(alertAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func save(name: String, forUser user: User) {
            
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = name
        
        changeRequest.commitChanges { (error) in
            
            if let error = error as NSError? {
                
                print("Error saving name for registered user: \(error.localizedDescription)")
                
            }
        }
    }
    
    func sendVerificationEmail(toUser user: User) {
     
        user.sendEmailVerification { (error) in
            
            if let error = error as NSError? {
                
                if let errorCode = AuthErrorCode(rawValue: error.code) {
                    
                    switch errorCode {
                        
                    case .userNotFound:
                        print("Send email verification user not found")
                        
                    case .networkError:
                        print("Send email verification network error")
                        
                    default:
                        print("Send email verification network error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func displayAlert(withTitle title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.view.tintColor = UIColor(red: 203.0/255.0, green: 8.0/255.0, blue: 19.0/255.0, alpha: 1.0)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func signInTapped(_ sender: UIButton) {
        
        navigationController?.popViewController(animated: true)
    }
}

extension RegisterViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == nameTextField {
          
            emailTextField.becomeFirstResponder()
            
        } else if textField == emailTextField {
            
            passwordTextField.becomeFirstResponder()
            
        } else if textField == passwordTextField {
            
            passwordTextField.resignFirstResponder()
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        nameValidationLabel.isHidden = true
        emailValidationLabel.isHidden = true
        passwordValidationLabel.isHidden = true
        
        // Prevent space at beginning
        if range.location == 0 && string == " " {
            
            return false
        }
        
        // Enable backspace
        if range.length > 0 && string.count == 0 {
            
            return true
        }
        
        // Allowed characters
        var validCharacters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_!+-*/%^&()[]{}.,@"
        
        if textField == nameTextField {
            
            validCharacters += " "
        }
        
        let invalidCharacterSet = NSCharacterSet(charactersIn: validCharacters).inverted
        
        let filtered = string.components(separatedBy: invalidCharacterSet).joined(separator: "")
        
        return string == filtered
    }
    
    func validateFields() -> Bool {
        
        var validated = true
        nameValidationLabel.isHidden = true
        emailValidationLabel.isHidden = true
        passwordValidationLabel.isHidden = true
        
        var invalidFields = [UIView]()
        let name = nameTextField.text!
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        if name.isEmpty {
            
            invalidFields.append(nameTextField)
            nameValidationLabel.isHidden = false
            validated = false
        }
        
        if email.isEmpty || !isValidEmail(email) {
            
            invalidFields.append(emailTextField)
            emailValidationLabel.isHidden = false
            validated = false
        }
        
        if password.isEmpty || !isValidPassword(password) {
            
            invalidFields.append(passwordTextField)
            passwordValidationLabel.isHidden = false
            validated = false
        }
        
        if !invalidFields.isEmpty {
            
            wobble(views: invalidFields)
        }
        
        return validated
    }
    
    
    func isValidEmail(_ email: String) -> Bool {
        
        let emailRegEx = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
    }
    
    func isValidPassword(_ password: String) -> Bool {
        
        // Minimum 8 characters, at least 1 uppercase, 1 lowercase and 1 number
        
        let passwordRegEx = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d]{8,}$"
        let validPassword = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return validPassword.evaluate(with: password)
    }
}

extension RegisterViewController {
    
    func prepareFeedback() {
        
        feedbackGenerator = UINotificationFeedbackGenerator()
        feedbackGenerator?.prepare()
    }
    
    func triggerSuccessFeedback() {
        
        feedbackGenerator?.notificationOccurred(.success)
        feedbackGenerator = nil
    }
    
    func triggerWarningFeedback() {
        
        feedbackGenerator?.notificationOccurred(.warning)
        feedbackGenerator = nil
    }
    
    func triggerErrorFeedback() {
        
        feedbackGenerator?.notificationOccurred(.error)
        feedbackGenerator = nil
    }
}
