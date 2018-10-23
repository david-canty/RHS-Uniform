//
//  APIController+Extension.swift
//  RHS Uniform
//
//  Created by David Canty on 23/02/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import Foundation
import CoreData

extension APIController {

    // MARK: - Items
    func deleteItemsWith(itemsJSON: [[String: Any]]) {
                
        var itemIds = [UUID]()
        for itemJSON in itemsJSON {
            
            guard let item = itemJSON["item"] as? [String : Any] else {
                fatalError("Error getting item JSON")
            }
            guard let itemSizes = itemJSON["sizes"] as? [[String: Any]] else {
                fatalError("Error getting item sizes JSON")
            }
            guard let itemYears = itemJSON["years"] as? [[String: Any]] else {
                fatalError("Error getting item years JSON")
            }
            
            let itemId = UUID(uuidString: item["id"] as! String)!
            itemIds.append(itemId)
            
            deleteItemSizesWith(itemSizesJSON: itemSizes, forItemId: itemId)
            deleteItemYearsWith(itemYearsJSON: itemYears, forItemId: itemId)
        }
        
        let itemsFetchRequest: NSFetchRequest<SUShopItem> = SUShopItem.fetchRequest()
        let itemIdPredicate = NSPredicate(format: "NOT (id IN %@)", itemIds)
        itemsFetchRequest.predicate = itemIdPredicate
        
        do {
            
            let fetchedItems = try self.context.fetch(itemsFetchRequest)
            
            for fetchedItem in fetchedItems {
                self.context.delete(fetchedItem)
            }
        
        } catch {
            fatalError("Failed to fetch items for deletion: \(error)")
        }
    }
    
    // MARK: - Item Sizes
    func deleteItemSizesWith(itemSizesJSON: [[String: Any]], forItemId itemId: UUID) {
        
        var itemSizeIds = [UUID]()
        for itemSizeJSON in itemSizesJSON {
            
            let itemSizeId = UUID(uuidString: itemSizeJSON["id"] as! String)!
            itemSizeIds.append(itemSizeId)
        }
        
        let itemSizesFetchRequest: NSFetchRequest<SUItemSize> = SUItemSize.fetchRequest()
        let itemIdPredicate = NSPredicate(format: "item.id == %@", itemId as CVarArg)
        let itemSizeIdPredicate = NSPredicate(format: "NOT (id IN %@)", itemSizeIds)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [itemIdPredicate, itemSizeIdPredicate])
        itemSizesFetchRequest.predicate = compoundPredicate
        
        do {
            
            let fetchedItemSizes = try self.context.fetch(itemSizesFetchRequest)
            
            for fetchedItemSize in fetchedItemSizes {
                self.context.delete(fetchedItemSize)
            }
            
        } catch {
            fatalError("Failed to fetch item sizes for deletion: \(error)")
        }
    }
    
    // MARK: - Item Years
    func deleteItemYearsWith(itemYearsJSON: [[String: Any]], forItemId itemId: UUID) {
        
        guard let itemObject = SUShopItem.getObjectWithId(itemId) else {
            fatalError("Failed to get item with id \(itemId)")
        }
        
        if let existingYearRelationships = itemObject.years {
            itemObject.removeFromYears(existingYearRelationships)
        }

        for itemYearJSON in itemYearsJSON {

            let yearId = UUID(uuidString: itemYearJSON["id"] as! String)!

            guard let yearObject = SUYear.getObjectWithId(yearId) else {
                fatalError("Failed to get year with id \(yearId)")
            }
            itemObject.addToYears(yearObject)
        }
    }
    
    // MARK: - Sizes
    func deleteSizesWith(sizesJSON: [[String: Any]]) {
                
        var sizeIds = [UUID]()
        for sizeJSON in sizesJSON {
            
            let sizeId = UUID(uuidString: sizeJSON["id"] as! String)!
            sizeIds.append(sizeId)
        }
        
        let sizesFetchRequest: NSFetchRequest<SUSize> = SUSize.fetchRequest()
        let sizeIdPredicate = NSPredicate(format: "NOT (id IN %@)", sizeIds)
        sizesFetchRequest.predicate = sizeIdPredicate
        
        do {
            
            let fetchedSizes = try self.context.fetch(sizesFetchRequest)
            
            for fetchedSize in fetchedSizes {
                self.context.delete(fetchedSize)
            }
            
        } catch {
            fatalError("Failed to fetch sizes for deletion: \(error)")
        }
    }
    
    // MARK: - Categories
    func deleteCategoriesWith(categoriesJSON: [[String: Any]]) {
                
        var categoryIds = [UUID]()
        for categoryJSON in categoriesJSON {
            
            let categoryId = UUID(uuidString: categoryJSON["id"] as! String)!
            categoryIds.append(categoryId)
        }
        
        let categoriesFetchRequest: NSFetchRequest<SUCategory> = SUCategory.fetchRequest()
        let categoryIdPredicate = NSPredicate(format: "NOT (id IN %@)", categoryIds)
        categoriesFetchRequest.predicate = categoryIdPredicate
        
        do {
            
            let fetchedCategories = try self.context.fetch(categoriesFetchRequest)
            
            for fetchedCategory in fetchedCategories {
                self.context.delete(fetchedCategory)
            }
            
        } catch {
            fatalError("Failed to fetch categories for deletion: \(error)")
        }
    }
    
    // MARK: - Schools
    func deleteSchoolsWith(schoolsJSON: [[String: Any]]) {
        
        var schoolIds = [UUID]()
        for schoolJSON in schoolsJSON {
            
            guard let school = schoolJSON["school"] as? [String: Any] else {
                fatalError("Error getting school JSON")
            }
            guard let years = schoolJSON["years"] as? [[String: Any]] else {
                fatalError("Error getting school years JSON")
            }
            
            let schoolId = UUID(uuidString: school["id"] as! String)!
            schoolIds.append(schoolId)
            
            deleteYearsWith(yearsJSON: years, forSchoolId: schoolId)
        }
        
        let schoolsFetchRequest: NSFetchRequest<SUSchool> = SUSchool.fetchRequest()
        let schoolIdPredicate = NSPredicate(format: "NOT (id IN %@)", schoolIds)
        schoolsFetchRequest.predicate = schoolIdPredicate
        
        do {
            
            let fetchedSchools = try self.context.fetch(schoolsFetchRequest)
            
            for fetchedSchool in fetchedSchools {
                self.context.delete(fetchedSchool)
            }
            
        } catch {
            fatalError("Failed to fetch schools for deletion: \(error)")
        }
    }
    
    // MARK: - Years
    func deleteYearsWith(yearsJSON: [[String: Any]], forSchoolId schoolId: UUID) {
        
        var yearIds = [UUID]()
        for yearJSON in yearsJSON {
            
            let yearId = UUID(uuidString: yearJSON["id"] as! String)!
            yearIds.append(yearId)
        }
        
        let yearsFetchRequest: NSFetchRequest<SUYear> = SUYear.fetchRequest()
        let schoolIdPredicate = NSPredicate(format: "school.id == %@", schoolId as CVarArg)
        let yearIdPredicate = NSPredicate(format: "NOT (id IN %@)", yearIds)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [schoolIdPredicate, yearIdPredicate])
        
        yearsFetchRequest.predicate = compoundPredicate
        
        do {
            
            let fetchedYears = try self.context.fetch(yearsFetchRequest)
            
            for fetchedYear in fetchedYears {
                self.context.delete(fetchedYear)
            }
            
        } catch {
            fatalError("Failed to fetch years for deletion: \(error)")
        }
    }
    
}
