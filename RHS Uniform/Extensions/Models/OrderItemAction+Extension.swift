//
//  OrderItemAction+Extension.swift
//  RHS Uniform
//
//  Created by David Canty on 06/01/2019.
//  Copyright © 2019 ddijitall. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension SUOrderItemAction {
    
    class func getObjectWithId(_ id: UUID) -> SUOrderItemAction? {
        
        var orderItemAction: SUOrderItemAction?
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<SUOrderItemAction> = SUOrderItemAction.fetchRequest()
        
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        fetchRequest.predicate = predicate
        
        do {
            
            let results = try context.fetch(fetchRequest)
            
            if !results.isEmpty {
                orderItemAction = results[0]
            }
            
        } catch {
            
            print("Error with fetch request: \(error)")
            print("Error getting order item action with id: \(id)")
        }
        
        return orderItemAction
    }
}
