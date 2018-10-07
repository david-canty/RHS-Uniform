//
//  Image+Extension.swift
//  RHS Uniform
//
//  Created by David Canty on 04/10/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension SUImage {
    
    class func getObjectWithId(_ id: UUID) -> SUImage? {
        
        var image: SUImage?
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<SUImage> = SUImage.fetchRequest()
        
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        fetchRequest.predicate = predicate
        
        do {
            
            let results = try context.fetch(fetchRequest)
            
            if !results.isEmpty {
                image = results[0]
            }
            
        } catch {
            
            print("Error with fetch request: \(error)")
            print("Error getting image with id: \(id)")
        }
        
        return image
    }
    
    class func deleteObjectsForItem(_ id: UUID) {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<SUImage> = SUImage.fetchRequest()
        let predicate = NSPredicate(format: "item.id == %@", id as CVarArg)
        fetchRequest.predicate = predicate
        
        do {
            
            let images = try context.fetch(fetchRequest)
            
            if images.count > 0 {
                
                for image in images {
                    
                    context.delete(image)
                }
                
                try context.save()
            }
            
        } catch {
            
            let nserror = error as NSError
            print("Error deleting images for item with id \(id): \(nserror.userInfo)")
        }
    }
}
