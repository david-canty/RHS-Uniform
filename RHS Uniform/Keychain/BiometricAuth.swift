//
//  BiometricAuth.swift
//  RHS Uniform
//
//  Created by David Canty on 21/03/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import Foundation
import LocalAuthentication

enum BiometricType {
    case none
    case touchID
    case faceID
}

class BiometricAuth {
    
    let context = LAContext()
    
    func canEvaluatePolicy() -> Bool {

        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    func biometricType() -> BiometricType {
        
        let _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        
        switch context.biometryType {
        case .none:
            return .none
        case .touchID:
            return .touchID
        case .faceID:
            return .faceID
        }
    }
    
    func authenticateUser(completion: @escaping (String?) -> Void) {

        guard canEvaluatePolicy() else {
            
            completion("Touch ID/Face ID is not available")
            return
        }
        
        var reason = ""
        if biometricType() == .touchID {
            
            reason = "Touch the Home button to sign in"
            
        } else if biometricType() == .faceID {
            
            reason = "Use Face ID to sign in"
        }
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { (success, error) in
        
            if success {
                
                DispatchQueue.main.async {
                    
                    completion(nil)
                }
                
            } else {
                
                if let error = error as NSError? {
                
                    let errorMessage: String
                    
                    switch error.code {
                        
                    case Int(kLAErrorAuthenticationFailed):
                        errorMessage = "There was a problem verifying your identity."
                    case Int(kLAErrorUserCancel):
                        errorMessage = "You pressed cancel."
                    case Int(kLAErrorUserFallback):
                        errorMessage = "You pressed password."
                    case Int(kLAErrorBiometryNotAvailable):
                        errorMessage = "Touch ID/Face ID is not available."
                    case Int(kLAErrorBiometryNotEnrolled):
                        errorMessage = "Touch ID/Face ID is not set up."
                    case Int(kLAErrorBiometryLockout):
                        errorMessage = "Touch ID/Face ID is locked."
                    default:
                        errorMessage = "Touch ID/Face ID may not be configured"
                    }
                    
                    DispatchQueue.main.async {
                        
                        completion(errorMessage)
                    }
                }
            }
        }
    }
    
}
