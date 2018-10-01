//
//  UniformStock.swift
//  RHS Uniform
//
//  Created by David Canty on 16/02/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension UniformStock {
    
    class func getObjectWithUniqueId(_ uniqueId: Int32) -> UniformStock? {
        
        var uniformStock: UniformStock?
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<UniformStock> = UniformStock.fetchRequest()
        let predicate = NSPredicate(format: "uniqueId == %i", uniqueId)
        fetchRequest.predicate = predicate
        
        do {
            
            let results = try context.fetch(fetchRequest)
            
            if !results.isEmpty {
                uniformStock = results[0]
            }
            
        } catch {
            
            print("Error with fetch request: \(error)")
            print("Error getting uniform stock with unique id: \(uniqueId)")
        }
        
        return uniformStock
    }
    
    class func getObjectWithItemId(_ itemId: Int32, sizeId: Int32) -> UniformStock? {
     
        var uniformStock: UniformStock?
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<UniformStock> = UniformStock.fetchRequest()
        
        let itemPredicate = NSPredicate(format: "uniformItem.uniqueId == %i", itemId)
        let sizePredicate = NSPredicate(format: "uniformSize.uniqueId == %i", sizeId)
        let compoundPredicate = NSCompoundPredicate.init(type: .and, subpredicates: [itemPredicate, sizePredicate])
        fetchRequest.predicate = compoundPredicate
        
        do {
            
            let results = try context.fetch(fetchRequest)
            
            if !results.isEmpty {
                uniformStock = results[0]
            }
            
        } catch {
            
            print("Error with fetch request: \(error)")
            print("Error getting uniform stock with item unique id: \(itemId) and size unique id: \(sizeId)")
        }
        
        return uniformStock
    }
}
