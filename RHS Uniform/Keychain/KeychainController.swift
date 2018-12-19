//
//  KeychainController.swift
//  RHS Uniform
//
//  Created by David Canty on 21/03/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import Foundation
import FirebaseAuth

class KeychainController {
    
    static func save(item: String, withAccountName account: String) {
        
        let securedItem = KeychainSecuredItem(service: KeychainConfiguration.serviceName, account: account, accessGroup: KeychainConfiguration.accessGroup)
        
        do {
            
            try securedItem.saveSecuredItem(item)
            
        } catch {
            
            fatalError("Error saving item to keychain: \(error)")
        }
    }
    
    static func readItem(withAccountName account: String) -> String? {
        
        var item = ""
        
        let securedItem = KeychainSecuredItem(service: KeychainConfiguration.serviceName, account: account, accessGroup: KeychainConfiguration.accessGroup)
        
        do {
            
            item = try securedItem.readSecuredItem()
            
        } catch {
            
            print("Error reading item from keychain: \(error)")
            return nil
        }
        
        return item
    }
    
    static func saveIdToken() {
        
        Auth.auth().currentUser?.getIDToken(completion: { (token, error) in
            
            if let error = error as NSError? {
                
                fatalError("Error getting id token: \(error)")
                
            } else {

                if let token = token {
                    
                    let securedItem = KeychainSecuredItem(service: KeychainConfiguration.serviceName, account: "FirebaseToken", accessGroup: KeychainConfiguration.accessGroup)
                    
                    do {
                        
                        try securedItem.saveSecuredItem(token)
                        
                    } catch {
                        
                        fatalError("Error updating keychain: \(error)")
                    }
                }
            }
        })
    }
    
    static func save(email: String, password: String, oldEmail: String? = nil) {
        
//        if oldEmail != nil {
//
//            let oldSecuredItem = KeychainSecuredItem(service: KeychainConfiguration.serviceName, account: oldEmail!, accessGroup: KeychainConfiguration.accessGroup)
//
//            do {
//
//                try oldSecuredItem.deleteItem()
//
//            } catch {
//
//                fatalError("Error deleting old secured item: \(error)")
//            }
//        }
//
//        let securedItem = KeychainSecuredItem(service: KeychainConfiguration.serviceName, account: email, accessGroup: KeychainConfiguration.accessGroup)
//
//        do {
//
//            try securedItem.saveSecuredItem(password)
//
//        } catch {
//
//            fatalError("Error updating keychain: \(error)")
//        }
        
        let securedItemEmail = KeychainSecuredItem(service: KeychainConfiguration.serviceName, account: "RHSUniformEmail", accessGroup: KeychainConfiguration.accessGroup)

        do {

            try securedItemEmail.saveSecuredItem(email)

        } catch {

            fatalError("Error saving email to keychain: \(error)")
        }
        
        let securedItemPassword = KeychainSecuredItem(service: KeychainConfiguration.serviceName, account: "RHSUniformPassword", accessGroup: KeychainConfiguration.accessGroup)
        
        do {
            
            try securedItemPassword.saveSecuredItem(password)
            
        } catch {
            
            fatalError("Error saving password to keychain: \(error)")
        }
        
    }
    
    static func emailAndPassword() -> (String, String)? {

        var email = ""
        var password = ""
        
        let securedItemEmail = KeychainSecuredItem(service: KeychainConfiguration.serviceName, account: "RHSUniformEmail", accessGroup: KeychainConfiguration.accessGroup)
        
        do {
            
            try email = securedItemEmail.readSecuredItem()
            
        } catch {
            
            print("Error reading email from keychain: \(error)")
            return nil
        }
        
        let securedItemPassword = KeychainSecuredItem(service: KeychainConfiguration.serviceName, account: "RHSUniformPassword", accessGroup: KeychainConfiguration.accessGroup)
        
        do {
            
            try password = securedItemPassword.readSecuredItem()
            
        } catch {
            
            print("Error reading password from keychain: \(error)")
            return nil
        }
        
        return (email: email, password: password)
    }
    
    static func deleteAppSecuredItems() {
        
        do {
            
            let securedItems = try KeychainSecuredItem.securedItems(forService: KeychainConfiguration.serviceName)
            
            for item in securedItems {
                
                try item.deleteItem()
            }
            
        } catch {
            
            print("Error deleting keychain secured items: \(error)")
        }
    }
}
