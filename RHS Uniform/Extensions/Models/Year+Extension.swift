//
//  Year+Extension.swift
//  RHS Uniform
//
//  Created by David Canty on 14/02/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension SUYear {
    
    class func getObjectWithId(_ id: UUID) -> SUYear? {
        
        var year: SUYear?
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<SUYear> = SUYear.fetchRequest()
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        fetchRequest.predicate = predicate
        
        do {
            
            let results = try context.fetch(fetchRequest)
            
            if !results.isEmpty {
                year = results[0]
            }
            
        } catch {
            
            print("Error with fetch request: \(error)")
            print("Error getting year with id: \(id)")
        }
        
        return year
    }
}
