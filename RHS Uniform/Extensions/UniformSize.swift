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

extension UniformSize {
    
    class func getObjectWithUniqueId(_ uniqueId: Int32) -> UniformSize? {
        
        var uniformSize: UniformSize?
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<UniformSize> = UniformSize.fetchRequest()
        let predicate = NSPredicate(format: "uniqueId == %i", uniqueId)
        fetchRequest.predicate = predicate
        
        do {
            
            let results = try context.fetch(fetchRequest)
            
            if !results.isEmpty {
                uniformSize = results[0]
            }
            
        } catch {
            
            print("Error with fetch request: \(error)")
            print("Error getting uniform size with unique id: \(uniqueId)")
        }
        
        return uniformSize
    }
}
