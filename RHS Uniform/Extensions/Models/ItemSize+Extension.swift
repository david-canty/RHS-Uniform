//
//  ItemSize+Extension.swift
//  RHS Uniform
//
//  Created by David Canty on 16/02/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension SUItemSize {
    
    class func getObjectWithId(_ id: UUID) -> SUItemSize? {
        
        var itemSize: SUItemSize?
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<SUItemSize> = SUItemSize.fetchRequest()
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        fetchRequest.predicate = predicate
        
        do {
            
            let results = try context.fetch(fetchRequest)
            
            if !results.isEmpty {
                itemSize = results[0]
            }
            
        } catch {
            
            print("Error with fetch request: \(error)")
            print("Error getting item size with id: \(id)")
        }
        
        return itemSize
    }
    
    class func getObjectWithItemId(_ itemId: UUID, sizeId: UUID) -> SUItemSize? {
     
        var itemSize: SUItemSize?
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<SUItemSize> = SUItemSize.fetchRequest()
        
        let itemPredicate = NSPredicate(format: "item.id == %@", itemId as CVarArg)
        let sizePredicate = NSPredicate(format: "#size.id == %@", sizeId as CVarArg)
        let compoundPredicate = NSCompoundPredicate.init(type: .and, subpredicates: [itemPredicate, sizePredicate])
        fetchRequest.predicate = compoundPredicate
        
        do {
            
            let results = try context.fetch(fetchRequest)
            
            if !results.isEmpty {
                itemSize = results[0]
            }
            
        } catch {
            
            print("Error with fetch request: \(error)")
            print("Error getting item size with item id: \(itemId) and size id: \(sizeId)")
        }
        
        return itemSize
    }
}
