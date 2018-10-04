//
//  Order+Extension.swift
//  RHS Uniform
//
//  Created by David Canty on 04/10/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension SUOrder {
    
    class func getObjectWithId(_ id: UUID) -> SUOrder? {
        
        var order: SUOrder?
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<SUOrder> = SUOrder.fetchRequest()
        
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        fetchRequest.predicate = predicate
        
        do {
            
            let results = try context.fetch(fetchRequest)
            
            if !results.isEmpty {
                order = results[0]
            }
            
        } catch {
            
            print("Error with fetch request: \(error)")
            print("Error getting order with id: \(id)")
        }
        
        return order
    }
}
