//
//  BagItem+Extension.swift
//  RHS Uniform
//
//  Created by David Canty on 05/10/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension SUBagItem {
    
    class func getObjectWithId(_ id: UUID) -> SUBagItem? {
        
        var bagItem: SUBagItem?
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<SUBagItem> = SUBagItem.fetchRequest()
        
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        fetchRequest.predicate = predicate
        
        do {
            
            let results = try context.fetch(fetchRequest)
            
            if !results.isEmpty {
                bagItem = results[0]
            }
            
        } catch {
            
            print("Error with fetch request: \(error)")
            print("Error getting bag item with id: \(id)")
        }
        
        return bagItem
    }
}
