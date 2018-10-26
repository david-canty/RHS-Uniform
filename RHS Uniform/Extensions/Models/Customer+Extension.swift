//
//  Customer+Extension.swift
//  RHS Uniform
//
//  Created by David Canty on 04/10/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension SUCustomer {
    
    class func getObjectWithId(_ id: UUID) -> SUCustomer? {
        
        var customer: SUCustomer?
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<SUCustomer> = SUCustomer.fetchRequest()
        
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        fetchRequest.predicate = predicate
        
        do {
            
            let results = try context.fetch(fetchRequest)
            
            if !results.isEmpty {
                customer = results[0]
            }
            
        } catch {
            
            print("Error with fetch request: \(error)")
            print("Error getting customer with id: \(id)")
        }
        
        return customer
    }
    
    class func getObjectWithEmail(_ email: String) -> SUCustomer? {
        
        var customer: SUCustomer?
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<SUCustomer> = SUCustomer.fetchRequest()
        
        let predicate = NSPredicate(format: "email == %@", email)
        fetchRequest.predicate = predicate
        
        do {
            
            let results = try context.fetch(fetchRequest)
            
            if !results.isEmpty {
                customer = results[0]
            }
            
        } catch {
            
            print("Error with fetch request: \(error)")
            print("Error getting customer with email: \(email)")
        }
        
        return customer
    }
}
