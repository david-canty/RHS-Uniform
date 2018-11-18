//
//  SignInViewController.swift
//  RHS Uniform
//
//  Created by David Canty on 14/03/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import UIKit
import CoreData
import FirebaseAuth

protocol SignInViewControllerDelegate {
    
    func didSignIn()
}

class SignInViewController: UIViewController {

    var context: NSManagedObjectContext!
    var delegate: SignInViewControllerDelegate?
    let defaults = UserDefaults.standard
    let biometricAuth = BiometricAuth()
    
    var feedbackGenerator: UINotificationFeedbackGenerator?
    
    @IBOutlet weak var stackViewCenterYConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailValidationLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordValidationLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShowNotification(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHideNotification(notification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        hideActivityIndicator()
        enableInput()
        emailValidationLabel.isHidden = true
        passwordValidationLabel.isHidden = true
        
        emailTextField.text = "david.canty@icloud.com"
        passwordTextField.text = "Passw0rd"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        if (KeychainController.emailAndPassword() != nil) && biometricAuth.canEvaluatePolicy() {
            
            showInputUI(false)
            authenticateViaBiometric()
            return
        }
        
        showInputUI(true)
    }
    
    func authenticateViaBiometric() {
        
        let biometricType = self.biometricAuth.biometricType()
        if biometricType == .touchID || biometricType == .faceID {
            
            biometricAuth.authenticateUser() { [weak self] message in
                
                if let message = message {
                    
//                    let alertView = UIAlertController(title: "Error Authenticating",
//                                                      message: message,
//                                                      preferredStyle: .alert)
//                    let okAction = UIAlertAction(title: "OK", style: .default)
//                    alertView.addAction(okAction)
//                    self?.present(alertView, animated: true)
                    
                    switch message {
                        
                    case let x where x.contains("cancel"):
                        
                        self?.showInputUI(true)
                        
                    case let x where x.contains("password"):
                        
                        self?.showInputUI(true)
                        
                    case let x where x.contains("not available"):
                        
                        self?.showInputUI(true)
                        
                    default:
                        
                        break
                    }
                    
                } else {
                    
                    if let (email, password) = KeychainController.emailAndPassword() {
                        
                        self?.signInUserWith(email: email, password: password)
                        
                    } else {
                        
                        self?.prepareFeedback()
                        
                        let alertTitle = "Authentication Error"
                        let alertMessage = "There was a problem authenticating. You will need to enter your email and password."
                        
                        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
                        alertController.view.tintColor = UIColor(red: 203.0/255.0, green: 8.0/255.0, blue: 19.0/255.0, alpha: 1.0)
                        let alertAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        
                            self?.showInputUI(true)
                        })
                        alertController.addAction(alertAction)
                        self?.present(alertController, animated: true, completion: nil)
                        
                        self?.triggerErrorFeedback()
                    }
                }
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func isFirstLaunch() -> Bool {
        
        if defaults.bool(forKey: "isFirstLaunch") {
            
            defaults.set(false, forKey: "isFirstLaunch")
            return true
            
        } else {
            
            return false
        }
    }
    
    func showInputUI(_ showUI: Bool) {
        
        if showUI {
            
            emailTextField.isHidden = false
            passwordTextField.isHidden = false
            signInButton.isHidden = false
            forgotPasswordButton.isHidden = false
            separatorView.isHidden = false
            registerButton.isHidden = false
            enableInput()
            
        } else {
            
            emailTextField.isHidden = true
            passwordTextField.isHidden = true
            signInButton.isHidden = true
            forgotPasswordButton.isHidden = true
            separatorView.isHidden = true
            registerButton.isHidden = true
            disableInput()
        }
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
        signInButton.isUserInteractionEnabled = false
        forgotPasswordButton.isUserInteractionEnabled = false
        registerButton.isUserInteractionEnabled = false
    }
    
    func enableInput() {
        
        emailTextField.isUserInteractionEnabled = true
        passwordTextField.isUserInteractionEnabled = true
        signInButton.isUserInteractionEnabled = true
        forgotPasswordButton.isUserInteractionEnabled = true
        registerButton.isUserInteractionEnabled = true
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
    
    @IBAction func signInButtonTapped(_ sender: UIButton) {
        
        disableInput()
        
        if !validateFields() {
            
            prepareFeedback()
            
            enableInput()
            
            triggerErrorFeedback()
            
            return
        }
        
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        signInUserWith(email: email, password: password)
    }
    
    func signInUserWith(email: String, password: String) {
        
        showActivityIndicator()
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if let error = error as NSError? {
                
                self.prepareFeedback()
                
                if let errorCode = AuthErrorCode(rawValue: error.code) {
                    
                    switch errorCode {
                        
                    case .userNotFound:
                        self.displayAlert(withTitle: "User Not Found", message: "A user with this email address does not exist.")
                        
                    case .wrongPassword:
                        self.displayAlert(withTitle: "Incorrect Password", message: "The password you entered is incorrect.")
                        
                    case .networkError:
                        self.displayAlert(withTitle: "Network Error", message: "Please check that your device is connected to Wi-Fi or has a mobile data connection.")
                        
                    case .userDisabled:
                        self.displayAlert(withTitle: "Account Disabled", message: "This user account has been disabled.")
                        
                    default:
                        self.displayAlert(withTitle: "Error Signing In", message: "You could not be signed in: \(error.localizedDescription)")
                    }
                }
                
                self.triggerErrorFeedback()
                
                self.hideActivityIndicator()
                self.enableInput()
                
            } else {
                
                KeychainController.saveIdToken()
                KeychainController.save(email: email, password: password)
                
                if let uid = Auth.auth().currentUser?.uid {
                
                    self.createCustomer(withEmail: email, firebaseUserId: uid)
                }
                
                if self.isFirstLaunch() {
                    
                    let biometricType = self.biometricAuth.biometricType()
                    if biometricType == .touchID || biometricType == .faceID {
                        
                        //self.promptForBiometricId()
                    }
                }
                
                self.delegate?.didSignIn()
            }
        }
    }
    
    func createCustomer(withEmail email: String, firebaseUserId uid: String) {
        
        if SUCustomer.getObjectWithEmail(email) == nil {
            
            StripeClient.sharedInstance.createCustomer(withEmail: email) { result in
                
                switch result {
                    
                case .success:
                    
                    APIClient.sharedInstance.createCustomer(withFirebaseId: uid, email: email, completion: { (customer, error) in
                    
                        if let error = error as NSError? {
                            
                            print("Error creating customer with email '\(email)': \(error.localizedDescription)")
                            
                        } else {
                            
                            if let customerDict = customer {
                                
                                let id = UUID(uuidString: customerDict["id"] as! String)
                                let firebaseUserId = customerDict["firebaseUserId"] as! String
                                let email = customerDict["email"] as! String
                                let timestamp = customerDict["timestamp"] as! String
                                
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                                guard let timestampDate = dateFormatter.date(from: timestamp) else {
                                    fatalError("Failed to convert date due to mismatched format")
                                }
                                
                                let newCustomer = SUCustomer(context: self.context)
                                newCustomer.id = id
                                newCustomer.firebaseUserId = firebaseUserId
                                newCustomer.email = email
                                newCustomer.timestamp = timestampDate
                                
                                do {
                                    try self.context.save()
                                } catch {
                                    let nserror = error as NSError
                                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                                }
                            }
                        }
                    })
                    
                case .failure(let error):
                    
                    print("Error creating Stripe customer with email '\(email)': \(error.localizedDescription)")
                }
            }
        }
    }
    
    func promptForBiometricId() {
        
        var biometricType = ""
        
        switch biometricAuth.biometricType() {
        case .none:
            break
        case .touchID:
            biometricType = "Touch ID"
        case .faceID:
            biometricType = "Face ID"
        }
        
        if biometricType == "Touch ID" {
        
            let alertTitle = biometricType
            let alertMessage = "Do you want to allow this app to use \(biometricType)?"
            
            let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
            alertController.view.tintColor = UIColor(red: 203.0/255.0, green: 8.0/255.0, blue: 19.0/255.0, alpha: 1.0)
            
            let alertAllowAction = UIAlertAction(title: "Allow", style: .default) { (action) in
            
                
            }
            alertController.addAction(alertAllowAction)
            
            let alertDontAllowAction = UIAlertAction(title: "Don't Allow", style: .default, handler: nil)
            alertController.addAction(alertDontAllowAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func displayAlert(withTitle title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.view.tintColor = UIColor(red: 203.0/255.0, green: 8.0/255.0, blue: 19.0/255.0, alpha: 1.0)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func forgotPasswordButtonTapped(_ sender: UIButton) {
        
        let alertTitle = "Reset Password"
        let alertMessage = "Enter the email address that should be used to receive password reset instructions."
        
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alertController.view.tintColor = UIColor(red: 203.0/255.0, green: 8.0/255.0, blue: 19.0/255.0, alpha: 1.0)
        
        alertController.addTextField { (textField) in
        
            textField.placeholder = "Email address"
            textField.delegate = self
        }
        
        let resetAction = UIAlertAction(title: "Reset", style: .default) { (action) in
        
            let emailTextField = alertController.textFields![0] as UITextField
            let email = emailTextField.text!
            
            if !self.isValidEmail(email) {
                
                let emailValidationAlertController = UIAlertController(title: "Invalid Email", message: "Please enter a valid email address.", preferredStyle: .alert)
                emailValidationAlertController.view.tintColor = UIColor(red: 203.0/255.0, green: 8.0/255.0, blue: 19.0/255.0, alpha: 1.0)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                emailValidationAlertController.addAction(okAction)
                self.present(emailValidationAlertController, animated: true, completion: nil)
                
            } else {
                
                self.sendPasswordResetTo(email: email)
            }
        }
        alertController.addAction(resetAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }

    func sendPasswordResetTo(email: String) {
        
        activityIndicator.startAnimating()
        
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in

            if let error = error as NSError? {
                
                if let errorCode = AuthErrorCode(rawValue: error.code) {
                
                    switch errorCode {
                        
                    case .invalidEmail:
                        self.displayAlert(withTitle: "Invalid Email", message: "Please enter a valid email address.")
                        
                    case .invalidRecipientEmail:
                        self.displayAlert(withTitle: "Email Not Registered", message: "This is not a registered email address.")
                        
                    default:
                        self.displayAlert(withTitle: "Error Resetting Password", message: "Your password could not be reset: \(error.localizedDescription)")
                    }
                }
                
                self.activityIndicator.stopAnimating()
                
            } else {
                
                self.displayAlert(withTitle: "Email Sent", message: "A password reset email has been sent to \(email)")
                self.activityIndicator.stopAnimating()
            }
        }
    }
}

extension SignInViewController: UITextFieldDelegate {
    
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
    
    func isValidPassword(_ password: String) -> Bool {
        
        // Minimum 8 characters, at least 1 uppercase, 1 lowercase and 1 number
        
        let passwordRegEx = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d]{8,}$"
        let validPassword = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return validPassword.evaluate(with: password)
    }
}

extension SignInViewController {
    
    func prepareFeedback() {
        
        let userDefaults = UserDefaults.standard
        if userDefaults.bool(forKey: "useHaptics") {
        
            feedbackGenerator = UINotificationFeedbackGenerator()
            feedbackGenerator?.prepare()
        }
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
