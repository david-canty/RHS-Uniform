//
//  UniformItem.swift
//  RHS Uniform
//
//  Created by David Canty on 14/02/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension SUItem {
    
    class func getObjectWithId(_ id: UUID) -> SUItem? {
        
        var item: SUItem?
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<SUItem> = SUItem.fetchRequest()
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        fetchRequest.predicate = predicate
        
        do {
            
            let results = try context.fetch(fetchRequest)
            
            if !results.isEmpty {
                item = results[0]
            }
            
        } catch {
            
            print("Error with fetch request: \(error)")
            print("Error getting item with id: \(id)")
        }
        
        return uniformItem
    }
}
