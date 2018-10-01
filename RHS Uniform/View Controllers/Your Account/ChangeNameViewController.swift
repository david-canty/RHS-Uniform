//
//  ChangeNameViewController.swift
//  RHS Uniform
//
//  Created by David Canty on 18/03/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import UIKit
import FirebaseAuth

class ChangeNameViewController: UIViewController {

    var currentName: String?
    
    var feedbackGenerator: UINotificationFeedbackGenerator?
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nameValidationLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        hideActivityIndicator()
        enableInput()
        nameValidationLabel.isHidden = true
        nameTextField.text = currentName
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
        saveButton.isUserInteractionEnabled = false
    }
    
    func enableInput() {
        
        nameTextField.isUserInteractionEnabled = true
        saveButton.isUserInteractionEnabled = true
    }
    
    // MARK: - Button Actions
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        
        disableInput()
        nameTextField.resignFirstResponder()
        
        if !validateFields() {
            
            prepareFeedback()
            
            enableInput()
            
            triggerErrorFeedback()
            
            return
        }
        
        showActivityIndicator()
        
        let newName = nameTextField.text!
        changeNameTo(newName)
    }
    
    func changeNameTo(_ newName: String) {
     
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        
        changeRequest?.displayName = newName
        
        changeRequest?.commitChanges { (error) in
            
            if let error = error as NSError? {
                
                self.prepareFeedback()
                
                self.hideActivityIndicator()
                self.enableInput()
                
                self.displayAlert(withTitle: "Error Changing Name", message: "Your name could not be changed: \(error.localizedDescription)")
                
                self.triggerErrorFeedback()
                
            } else {
                
                self.hideActivityIndicator()
                
                DispatchQueue.main.async {
                    
                    self.navigationController?.popViewController(animated: true)
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

extension ChangeNameViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        nameTextField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        nameValidationLabel.isHidden  = true
        
        // Prevent space at beginning
        if range.location == 0 && string == " " {
            
            return false
        }
        
        // Enable backspace
        if range.length > 0 && string.count == 0 {
            
            return true
        }
        
        // Allowed characters
        let validCharacters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_!+-*/%^&()[]{}.,@ "
        let invalidCharacterSet = NSCharacterSet(charactersIn: validCharacters).inverted
        
        let filtered = string.components(separatedBy: invalidCharacterSet).joined(separator: "")
        
        return string == filtered
    }
    
    func validateFields() -> Bool {
        
        var validated = true
        nameValidationLabel.isHidden  = true
        
        var invalidFields = [UIView]()
        let name = nameTextField.text!
        
        if name.isEmpty {
            
            invalidFields.append(nameTextField)
            nameValidationLabel.isHidden = false
            validated = false
        }
        
        if !invalidFields.isEmpty {
            
            wobble(views: invalidFields)
        }
        
        return validated
    }
}

extension ChangeNameViewController {
    
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
