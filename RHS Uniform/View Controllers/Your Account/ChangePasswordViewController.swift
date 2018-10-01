//
//  ChangePasswordViewController.swift
//  RHS Uniform
//
//  Created by David Canty on 16/03/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import UIKit
import FirebaseAuth

class ChangePasswordViewController: UIViewController {

    var hidePasswords = true
    var feedbackGenerator: UINotificationFeedbackGenerator?
    
    @IBOutlet weak var stackViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var currentPasswordField: UITextField!
    @IBOutlet weak var currentPasswordValidationLabel: UILabel!
    @IBOutlet weak var newPasswordField: UITextField!
    @IBOutlet weak var newPasswordValidationLabel: UILabel!
    @IBOutlet weak var showPasswordsButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
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
        currentPasswordValidationLabel.isHidden = true
        newPasswordValidationLabel.isHidden = true
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
        
        currentPasswordField.isUserInteractionEnabled = false
        newPasswordField.isUserInteractionEnabled = false
        showPasswordsButton.isUserInteractionEnabled = false
        saveButton.isUserInteractionEnabled = false
    }
    
    func enableInput() {
        
        currentPasswordField.isUserInteractionEnabled = true
        newPasswordField.isUserInteractionEnabled = true
        showPasswordsButton.isUserInteractionEnabled = true
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
    
    @IBAction func showPasswordsButtonTapped(_ sender: UIButton) {
        
        hidePasswords = !hidePasswords
        currentPasswordField.isSecureTextEntry = hidePasswords
        newPasswordField.isSecureTextEntry = hidePasswords
        
        let showPasswordsButtonTitle = hidePasswords ? "Show Passwords" : "Hide Passwords"
        showPasswordsButton.setTitle(showPasswordsButtonTitle, for: .normal)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        
        disableInput()
        currentPasswordField.resignFirstResponder()
        newPasswordField.resignFirstResponder()
        
        if !validateFields() {
            
            prepareFeedback()
            
            enableInput()
            
            triggerErrorFeedback()
            
            return
        }
        
        showActivityIndicator()
        
        let currentPassword = currentPasswordField.text!
        let newPassword = newPasswordField.text!
        
        changePasswordFrom(currentPassword, to: newPassword)
    }
    
    func changePasswordFrom(_ currentPassword: String, to newPassword: String) {
     
        // Reauthenticate user
        if let user = Auth.auth().currentUser {
        
            let credential = EmailAuthProvider.credential(withEmail: user.email!, password: currentPassword)

            user.reauthenticateAndRetrieveData(with: credential) { authData, error in
                
                if let error = error as NSError? {
                    
                    self.prepareFeedback()
                    
                    if let errorCode = AuthErrorCode(rawValue: error.code) {
                        
                        self.hideActivityIndicator()
                        self.enableInput()
                        
                        switch errorCode {
                            
                        case .wrongPassword:
                            self.displayAlert(withTitle: "Incorrect Password", message: "The current password you entered is incorrect.")
                            
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
                   
                    // Change password
                    authData?.user.updatePassword(to: newPassword, completion: { (error) in
                        
                        if let error = error as NSError? {
                            
                            self.prepareFeedback()
                            
                            self.hideActivityIndicator()
                            self.enableInput()
                            
                            self.displayAlert(withTitle: "Error Changing Password", message: "Your password could not be changed: \(error.localizedDescription)")
                            
                            self.triggerErrorFeedback()
                            
                        } else {
                            
                            
                            KeychainController.saveIdToken()
                            KeychainController.save(email: (authData?.user.email)!, password: newPassword)
                            self.hideActivityIndicator()
                            
                            let alertController = UIAlertController(title: "Password Changed", message: "Your password has been changed successfully.", preferredStyle: .alert)
                            let alertAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                
                                DispatchQueue.main.async {
                                    self.navigationController?.popViewController(animated: true)
                                }
                            })
                            alertController.addAction(alertAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    })
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

extension ChangePasswordViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == currentPasswordField {
            
            newPasswordField.becomeFirstResponder()
            
        } else if textField == newPasswordField {
            
            newPasswordField.resignFirstResponder()
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        currentPasswordValidationLabel.isHidden = true
        newPasswordValidationLabel.isHidden = true
        
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
        currentPasswordValidationLabel.isHidden = true
        newPasswordValidationLabel.isHidden = true
        
        var invalidFields = [UIView]()
        let currentPassword = currentPasswordField.text!
        let newPassword = newPasswordField.text!
        
        if currentPassword.isEmpty {
            
            invalidFields.append(currentPasswordField)
            currentPasswordValidationLabel.isHidden = false
            validated = false
        }
        
        if newPassword.isEmpty || !isValidPassword(newPassword) {
            
            invalidFields.append(newPasswordField)
            newPasswordValidationLabel.isHidden = false
            validated = false
        }
        
        if !invalidFields.isEmpty {
            
            wobble(views: invalidFields)
        }
        
        return validated
    }
    
    func isValidPassword(_ password: String) -> Bool {
        
        // Minimum 8 characters, at least 1 uppercase, 1 lowercase and 1 number
        
        let passwordRegEx = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d]{8,}$"
        let validPassword = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return validPassword.evaluate(with: password)
    }
}

extension ChangePasswordViewController {
    
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
