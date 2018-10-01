//
//  BagItem.swift
//  RHS Uniform
//
//  Created by David Canty on 01/03/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension BagItem {

    class func getObjectWith(uniformStockId: Int32) -> BagItem? {
        
        var bagItem: BagItem?
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<BagItem> = BagItem.fetchRequest()
        
        let predicate = NSPredicate(format: "uniformStock.uniqueId == %i", uniformStockId)
        fetchRequest.predicate = predicate
        
        do {
            
            let results = try context.fetch(fetchRequest)
            
            if !results.isEmpty {
                bagItem = results[0]
            }
            
        } catch {
            
            print("Error with fetch request: \(error)")
            print("Error getting bag item uniform stock with unique id: \(uniformStockId)")
        }
        
        return bagItem
    }
}
