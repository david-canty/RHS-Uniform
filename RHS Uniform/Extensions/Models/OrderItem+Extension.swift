//
//  OrderItem+Extension.swift
//  RHS Uniform
//
//  Created by David Canty on 01/03/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension SUOrderItem {

    class func getObjectWithId(_ id: UUID) -> SUOrderItem? {
        
        var orderItem: SUOrderItem?
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<SUOrderItem> = SUOrderItem.fetchRequest()
        
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        fetchRequest.predicate = predicate
        
        do {
            
            let results = try context.fetch(fetchRequest)
            
            if !results.isEmpty {
                orderItem = results[0]
            }
            
        } catch {
            
            print("Error with fetch request: \(error)")
            print("Error getting order item with id: \(id)")
        }
        
        return orderItem
    }
    
    class func updateObjectWithId(_ id: UUID, withStatus status: String) -> SUOrderItem? {
        
        var orderItem: SUOrderItem?
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<SUOrderItem> = SUOrderItem.fetchRequest()
        
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        fetchRequest.predicate = predicate
        
        do {
            
            let results = try context.fetch(fetchRequest)
            
            if !results.isEmpty {
                
                orderItem = results[0]
                orderItem!.orderItemStatus = status
                
                do {
                    
                    try context.save()
                    
                } catch {
                    
                    let nserror = error as NSError
                    print("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
            
        } catch {
            
            print("Error with fetch request: \(error)")
            print("Error getting order item with id: \(id)")
        }
        
        return orderItem
    }
}
