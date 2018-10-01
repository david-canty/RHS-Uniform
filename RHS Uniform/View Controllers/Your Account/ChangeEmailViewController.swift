//
//  ChangeEmailViewController.swift
//  RHS Uniform
//
//  Created by David Canty on 18/03/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import UIKit
import FirebaseAuth

class ChangeEmailViewController: UIViewController {

    var user: User?
    
    var feedbackGenerator: UINotificationFeedbackGenerator?
    
    @IBOutlet weak var stackViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var currentEmailLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailValidationLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordValidationLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let user = Auth.auth().currentUser {
            
            self.user = user
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShowNotification(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHideNotification(notification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        hideActivityIndicator()
        enableInput()
        emailValidationLabel.isHidden = true
        passwordValidationLabel.isHidden = true
        
        currentEmailLabel.text = user?.email
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
        
        emailTextField.isUserInteractionEnabled = false
        passwordTextField.isUserInteractionEnabled = false
        saveButton.isUserInteractionEnabled = false
    }
    
    func enableInput() {
        
        emailTextField.isUserInteractionEnabled = true
        passwordTextField.isUserInteractionEnabled = true
        saveButton.isUserInteractionEnabled = true
    }
    
    @objc func keyboardShowNotification(notification: NSNotification) {
        
        self.stackViewTopConstraint.constant = -50.0
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func keyboardHideNotification(notification: NSNotification) {
        
        self.stackViewTopConstraint.constant = 0.0
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.view.layoutIfNeeded()
        })
    }
    
    // MARK: - Button Actions
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        
        disableInput()
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        if !validateFields() {
            
            prepareFeedback()
            
            enableInput()
            
            triggerErrorFeedback()
            
            return
        }
        
        showActivityIndicator()
        
        let newEmail = emailTextField.text!
        let password = passwordTextField.text!
        
        changeEmailTo(newEmail, withPassword: password)
    }
    
    func changeEmailTo(_ newEmail: String, withPassword password: String) {
        
        // Reauthenticate user
        if user != nil {
            
            let credential = EmailAuthProvider.credential(withEmail: user!.email!, password: password)
            
            user!.reauthenticateAndRetrieveData(with: credential) { authData, error in
                
                if let error = error as NSError? {
                    
                    self.prepareFeedback()
                    
                    self.hideActivityIndicator()
                    self.enableInput()
                    
                    if let errorCode = AuthErrorCode(rawValue: error.code) {
                        
                        switch errorCode {
                            
                        case .wrongPassword:
                            self.displayAlert(withTitle: "Incorrect Password", message: "The password you entered is incorrect.")
                            
                        case .networkError:
                            self.displayAlert(withTitle: "Network Error", message: "Please check that your device is connected to Wi-Fi or has a mobile data connection.")
                            
                        case .userDisabled:
                            self.displayAlert(withTitle: "Account Disabled", message: "This user account has been disabled.")
                            
                        default:
                            self.displayAlert(withTitle: "Error Changing Password", message: "Your password could not be changed: \(error.localizedDescription)")
                        }
                        
                        self.triggerErrorFeedback()
                    }
                    
                } else {
                    
                    self.user = authData?.user
                    
                    // Change email
                    let oldEmail = self.user!.email
                    
                    self.user!.updateEmail(to: newEmail) { (error) in
                    
                        if let error = error as NSError? {
                            
                            self.prepareFeedback()
                            
                            self.hideActivityIndicator()
                            self.enableInput()
                            
                            if let errorCode = AuthErrorCode(rawValue: error.code) {
                                
                                switch errorCode {
                                    
                                case .invalidEmail:
                                    self.displayAlert(withTitle: "Invalid Email", message: "Please enter a valid email address.")
                                    
                                case .emailAlreadyInUse:
                                    self.displayAlert(withTitle: "Email In Use", message: "This email address is already in use by another account.")
                                    
                                case .userDisabled:
                                    self.displayAlert(withTitle: "Account Disabled", message: "This user account has been disabled.")
                                    
                                default:
                                    self.displayAlert(withTitle: "Error Changing Password", message: "Your password could not be changed: \(error.localizedDescription)")
                                }
                                
                                self.triggerErrorFeedback()
                            }
                            
                        } else {
                            
                            KeychainController.saveIdToken()
                            KeychainController.save(email: newEmail, password: password, oldEmail: oldEmail)
                            self.hideActivityIndicator()
                            
                            let alertController = UIAlertController(title: "Email Changed", message: "Your email address has been changed successfully.", preferredStyle: .alert)
                            let alertAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                
                                DispatchQueue.main.async {
                                    self.navigationController?.popViewController(animated: true)
                                }
                            })
                            alertController.addAction(alertAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
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
}

extension ChangeEmailViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailTextField {
            
            passwordTextField.becomeFirstResponder()
            
        } else if textField == passwordTextField {
            
            passwordTextField.resignFirstResponder()
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
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
        let validCharacters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_!+-*/%^&()[]{}.,@"
        let invalidCharacterSet = NSCharacterSet(charactersIn: validCharacters).inverted
        
        let filtered = string.components(separatedBy: invalidCharacterSet).joined(separator: "")
        
        return string == filtered
    }
    
    func validateFields() -> Bool {
        
        var validated = true
        emailValidationLabel.isHidden = true
        passwordValidationLabel.isHidden = true
        
        var invalidFields = [UIView]()
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        if email.isEmpty || !isValidEmail(email) {
            
            invalidFields.append(emailTextField)
            emailValidationLabel.isHidden = false
            validated = false
        }
        
        if password.isEmpty {
            
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
}

extension ChangeEmailViewController {
    
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
