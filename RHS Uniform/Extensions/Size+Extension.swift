//
//  UniformSize.swift
//  RHS Uniform
//
//  Created by David Canty on 16/02/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension SUSize {
    
    class func getObjectWithId(_ id: UUID) -> SUSize? {
        
        var size: SUSize?
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<SUSize> = SUSize.fetchRequest()
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        fetchRequest.predicate = predicate
        
        do {
            
            let results = try context.fetch(fetchRequest)
            
            if !results.isEmpty {
                size = results[0]
            }
            
        } catch {
            
            print("Error with fetch request: \(error)")
            print("Error getting size with id: \(id)")
        }
        
        return size
    }
}
