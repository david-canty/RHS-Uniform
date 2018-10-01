//
//  School+Extension.swift
//  RHS Uniform
//
//  Created by David Canty on 10/03/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension School {
    
    class func getObjectWithUniqueId(_ uniqueId: UUID) -> School? {
        
        var school: School?
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<School> = School.fetchRequest()
        let predicate = NSPredicate(format: "uniqueId == %@", uniqueId as CVarArg)
        fetchRequest.predicate = predicate
        
        do {
            
            let results = try context.fetch(fetchRequest)
            
            if !results.isEmpty {
                school = results[0]
            }
            
        } catch {
            
            print("Error with fetch request: \(error)")
            print("Error getting school with unique id: \(uniqueId)")
        }
        
        return school
    }
}
