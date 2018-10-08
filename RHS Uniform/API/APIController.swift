//
//  APIController.swift
//  RHS Uniform
//
//  Created by David Canty on 11/02/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import Foundation
import CoreData
import Alamofire
import FirebaseAuth

class APIController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let currentUser = Auth.auth().currentUser
    
    func fetchSchools() {
    
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            
            if let error = error {
                
                print("Error getting user ID token: \(error)")
                
            } else {
                
                if let token = idToken {
                    
                    Alamofire.request(APIRouter.schools(userIdToken: token)).responseJSON { response in
                        
                        if let schools = response.result.value as? [[String: Any]] {
                            
                            self.create(schools: schools)
                            
                            do {
                                try self.context.save()
                            } catch {
                                let nserror = error as NSError
                                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func create(schools: [[String: Any]]) {
     
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        
        for school in schools {
            
            let timestampString = school["timestamp"] as! String
            guard let timestampDate = dateFormatter.date(from: timestampString) else {
                fatalError("Date conversion failed due to mismatched format")
            }
            
            let id = UUID(uuidString: school["id"] as! String)!
            if let existingSchool = SUSchool.getObjectWithId(id) {
                
                if existingSchool.timestamp! < timestampDate {
                    
                    existingSchool.schoolName = school["schoolName"] as? String
                    existingSchool.sortOrder = school["sortOrder"] as! Int32
                    existingSchool.timestamp = timestampDate
                }
                
            } else {
                
                let newSchool = SUSchool(context: context)
                newSchool.id = id
                newSchool.schoolName = school["schoolName"] as? String
                newSchool.sortOrder = school["sortOrder"] as! Int32
                newSchool.timestamp = timestampDate
            }
        }
    }
    
    func fetchYears() {
        
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            
            if let error = error {
                
                print("Error getting user ID token: \(error)")
                
            } else {
                
                if let token = idToken {
                    
                    Alamofire.request(APIRouter.years(userIdToken: token)).responseJSON { response in
                        
                        if let years = response.result.value as? [[String: Any]] {
                            
                            self.create(years: years)
                            
                            do {
                                try self.context.save()
                            } catch {
                                let nserror = error as NSError
                                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func create(years: [[String: Any]]) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        for year in years {
            
            let timestampString = year["timestamp"] as! String
            guard let timestampDate = dateFormatter.date(from: timestampString) else {
                fatalError("Date conversion failed due to mismatched format")
            }
            
            var tempYear: SUYear?
            let id = UUID(uuidString: year["id"] as! String)!
            
            if let existingYear = SUYear.getObjectWithId(id) {
                
                if existingYear.timestamp! < timestampDate {
                    
                    tempYear = existingYear
                }
                
            } else {
                
                tempYear = SUYear(context: context)
                tempYear!.id = id
            }
            
            if let tempYear = tempYear {
                
                // Year attributes
                tempYear.yearName = year["yearName"] as? String
                tempYear.sortOrder = year["sortOrder"] as! Int32
                tempYear.timestamp = timestampDate
                
                // School relationship
                let schoolId = UUID(uuidString: year["schoolID"] as! String)!
                
                guard let school = SUSchool.getObjectWithId(schoolId) else {
                    fatalError("Failed to get school with id \(schoolId)")
                }
                
                tempYear.school = school
            }
        }
    }
    
    func fetchCategories() {
        
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            
            if let error = error {
                
                print("Error getting user ID token: \(error)")
                
            } else {
                
                if let token = idToken {
                    
                    Alamofire.request(APIRouter.categories(userIdToken: token)).responseJSON { response in
                        
                        if let categories = response.result.value as? [[String: Any]] {
                            
                            self.create(categories: categories)
                            
                            do {
                                try self.context.save()
                            } catch {
                                let nserror = error as NSError
                                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func create(categories: [[String: Any]]) {
    
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        
        for category in categories {
            
            let timestampString = category["timestamp"] as! String
            guard let timestampDate = dateFormatter.date(from: timestampString) else {
                fatalError("Date conversion failed due to mismatched format")
            }
            
            let id = UUID(uuidString: category["id"] as! String)!
            if let existingCategory = SUCategory.getObjectWithId(id) {
                
                if existingCategory.timestamp! < timestampDate {
                    
                    existingCategory.categoryName = category["categoryName"] as? String
                    existingCategory.sortOrder = category["sortOrder"] as! Int32
                    existingCategory.timestamp = timestampDate
                }
                
            } else {
                
                let newCategory = SUCategory(context: context)
                newCategory.id = id
                newCategory.categoryName = category["categoryName"] as? String
                newCategory.sortOrder = category["sortOrder"] as! Int32
                newCategory.timestamp = timestampDate
            }
        }
    }
    
    func fetchSizes() {
        
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            
            if let error = error {
                
                print("Error getting user ID token: \(error)")
                
            } else {
                
                if let token = idToken {
        
                    Alamofire.request(APIRouter.sizes(userIdToken: token)).responseJSON { response in
                        
                        if let sizes = response.result.value as? [[String: Any]] {
                            
                            self.create(sizes: sizes)
                            
                            do {
                                try self.context.save()
                            } catch {
                                let nserror = error as NSError
                                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func create(sizes: [[String: Any]]) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        for size in sizes {
            
            let timestampString = size["timestamp"] as! String
            guard let timestampDate = dateFormatter.date(from: timestampString) else {
                fatalError("Date conversion failed due to mismatched format")
            }
            
            let id = UUID(uuidString: size["id"] as! String)!
            if let existingSize = SUSize.getObjectWithId(id) {
                
                if existingSize.timestamp! < timestampDate {
                    
                    existingSize.sizeName = size["sizeName"] as? String
                    existingSize.sortOrder = size["sortOrder"] as! Int32
                    existingSize.timestamp = timestampDate
                }
                
            } else {
                
                let newSize = SUSize(context: context)
                newSize.id = id
                newSize.sizeName = size["sizeName"] as? String
                newSize.sortOrder = size["sortOrder"] as! Int32
                newSize.timestamp = timestampDate
            }
        }
    }
    
    func fetchItems() {
        
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            
            if let error = error {
                
                print("Error getting user ID token: \(error)")
                
            } else {
                
                if let token = idToken {
        
                    Alamofire.request(APIRouter.items(userIdToken: token)).responseJSON { response in
                        
                        if let items = response.result.value as? [[String: Any]] {
                            
                            self.create(items: items)
                            
                            do {
                                try self.context.save()
                            } catch {
                                let nserror = error as NSError
                                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func create(items: [[String: Any]]) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        for itemWithRelations in items {
            
            guard let item = itemWithRelations["item"] as? [String : Any] else {
                fatalError("Failed to fetch item data")
            }
            guard let years = itemWithRelations["years"] as? [[String : Any]] else {
                fatalError("Failed to fetch years data")
            }
            guard let images = itemWithRelations["images"] as? [[String : Any]] else {
                fatalError("Failed to fetch images data")
            }
            
            let timestampString = item["timestamp"] as? String
            guard let timestampDate = dateFormatter.date(from: timestampString!) else {
                fatalError("Failed to convert date due to mismatched format")
            }
            
            var tempItem: SUItem?
            
            let id = UUID(uuidString: item["id"] as! String)!
            if let existingItem = SUItem.getObjectWithId(id) {
                
                if existingItem.timestamp! < timestampDate {
                    
                    tempItem = existingItem
                }
                
            } else {
                
                tempItem = SUItem(context: context)
                tempItem!.id = id
            }
            
            if let tempItem = tempItem {
                
                // Item attributes
                tempItem.itemName = item["itemName"] as? String
                tempItem.itemDescription = item["itemDescription"] as? String
                tempItem.itemColor = item["itemColor"] as? String
                tempItem.itemGender = item["itemGender"] as? String
                tempItem.itemPrice = item["itemPrice"] as! Double
                tempItem.timestamp = timestampDate
                
                // Item category relationship
                let categoryId = UUID(uuidString: item["categoryID"] as! String)!
                guard let category = SUCategory.getObjectWithId(categoryId) else {
                    fatalError("Failed to get category with id \(String(describing: categoryId))")
                }
                tempItem.category = category
                
                // Item years relationships
                create(years: years)
                
                if let existingYearRelationships = tempItem.years {
                    tempItem.removeFromYears(existingYearRelationships)
                }
                
                for year in years {
                    
                    let yearId = UUID(uuidString: year["id"] as! String)!
                    
                    guard let yearObject = SUYear.getObjectWithId(yearId) else {
                        fatalError("Failed to get year with id \(yearId)")
                    }
                    tempItem.addToYears(yearObject)
                }
                
                // Item images
                deleteImagesForItem(tempItem.id!)
                
                for image in images {
                    
                    let newImage = SUImage(context: context)
                    newImage.id = UUID(uuidString: image["id"] as! String)!
                    newImage.filename = image["filename"] as? String
                    newImage.sortOrder = image["sortOrder"] as! Int32
                    newImage.item = tempItem
                }
            }
        }
    }
    
    func deleteImagesForItem(_ id: UUID) {
        
        let fetchRequest: NSFetchRequest<SUImage> = SUImage.fetchRequest()
        let predicate = NSPredicate(format: "item.id == %@", id as CVarArg)
        fetchRequest.predicate = predicate
        
        do {
            
            let images = try context.fetch(fetchRequest)
            
            if images.count > 0 {
                
                for image in images {
                    
                    context.delete(image)
                }
                
                //try context.save()
            }
            
        } catch {
            
            let nserror = error as NSError
            print("Error deleting images for item with id \(id): \(nserror.userInfo)")
        }
    }
    
    func fetchItemSizes() {
        
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            
            if let error = error {
                
                print("Error getting user ID token: \(error)")
                
            } else {
                
                if let token = idToken {
                    
                    Alamofire.request(APIRouter.itemSizes(userIdToken: token)).responseJSON { response in
                        
                        if let itemSizes = response.result.value as? [[String: Any]] {
                            
                            self.create(itemSizes: itemSizes)
                            
                            do {
                                try self.context.save()
                            } catch {
                                let nserror = error as NSError
                                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func create(itemSizes: [[String: Any]]) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        for itemSize in itemSizes {
            
            let timestampString = itemSize["timestamp"] as! String
            guard let timestampDate = dateFormatter.date(from: timestampString) else {
                fatalError("Date conversion failed due to mismatched format")
            }
            
            let id = UUID(uuidString: itemSize["id"] as! String)!
            if let existingItemSize = SUItemSize.getObjectWithId(id) {
                
                if existingItemSize.timestamp! < timestampDate {
                    
                    existingItemSize.stock = itemSize["stock"] as! Int32
                    existingItemSize.timestamp = timestampDate
                }
                
            } else {
                
                let newItemSize = SUItemSize(context: context)
                newItemSize.id = id
                newItemSize.stock = itemSize["stock"] as! Int32
                newItemSize.timestamp = timestampDate
                
                let itemId = UUID(uuidString: itemSize["itemID"] as! String)!
                guard let item = SUItem.getObjectWithId(itemId) else {
                    fatalError("Failed to get item with id \(itemId)")
                }
                newItemSize.item = item
                
                let sizeId = UUID(uuidString: itemSize["sizeID"] as! String)!
                guard let size = SUSize.getObjectWithId(sizeId) else {
                    fatalError("Failed to get size with id \(sizeId)")
                }
                newItemSize.size = size
            }
        }
    }
}
