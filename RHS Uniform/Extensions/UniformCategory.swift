//
//  UniformCategory.swift
//  RHS Uniform
//
//  Created by David Canty on 14/02/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension UniformCategory {
    
    class func getObjectWithUniqueId(_ uniqueId: UUID) -> UniformCategory? {
        
        var uniformCategory: UniformCategory?
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<UniformCategory> = UniformCategory.fetchRequest()
        let predicate = NSPredicate(format: "uniqueId == %@", uniqueId as CVarArg)
        fetchRequest.predicate = predicate
        
        do {
            
            let results = try context.fetch(fetchRequest)
            
            if !results.isEmpty {
                uniformCategory = results[0]
            }
            
        } catch {
            
            print("Error with fetch request: \(error)")
            print("Error getting uniform category with unique id: \(uniqueId)")
        }
        
        return uniformCategory
    }
}
