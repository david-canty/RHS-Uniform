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

extension UniformItem {
    
    class func getObjectWithUniqueId(_ uniqueId: Int32) -> UniformItem? {
        
        var uniformItem: UniformItem?
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<UniformItem> = UniformItem.fetchRequest()
        let predicate = NSPredicate(format: "uniqueId == %i", uniqueId)
        fetchRequest.predicate = predicate
        
        do {
            
            let results = try context.fetch(fetchRequest)
            
            if !results.isEmpty {
                uniformItem = results[0]
            }
            
        } catch {
            
            print("Error with fetch request: \(error)")
            print("Error getting uniform item with unique id: \(uniqueId)")
        }
        
        return uniformItem
    }
}
