//
//  ShopItem+Extension.swift
//  RHS Uniform
//
//  Created by David Canty on 14/02/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension SUShopItem {
    
    class func getObjectWithId(_ id: UUID) -> SUShopItem? {
        
        var item: SUShopItem?
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<SUShopItem> = SUShopItem.fetchRequest()
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
        
        return item
    }
}
