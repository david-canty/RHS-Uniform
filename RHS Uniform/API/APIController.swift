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
    
    let context: NSManagedObjectContext!
    let currentUser: User!
    let dateFormatter: DateFormatter
    
    init() {
        context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        currentUser = Auth.auth().currentUser
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
    }
    
    // MARK: - Fetch data
    func fetchData() {
        
        currentUser.getIDTokenForcingRefresh(true) { idToken, error in
            
            if let error = error {
                
                fatalError("Error getting user ID token: \(error)")
                
            } else {
                
                if let token = idToken {
                    
                    Alamofire.request(APIRouter.all(userIdToken: token)).responseJSON { response in
                        
                        guard let allJSON = response.result.value as? [String: Any],
                        let schoolsJSON = allJSON["schools"] as? [[String: Any]],
                        let categoriesJSON = allJSON["categories"] as? [[String: Any]],
                        let sizesJSON = allJSON["sizes"] as? [[String: Any]],
                        let itemsJSON = allJSON["items"] as? [[String: Any]] else { return }
                        
                        // Create and Update
                        self.createSchoolsWith(schoolsJSON: schoolsJSON)
                        self.createCategoriesWith(categoriesJSON: categoriesJSON)
                        self.createSizesWith(sizesJSON: sizesJSON)
                        self.createItemsWith(itemsJSON: itemsJSON)
                        
                        // Delete
                        self.deleteItemsWith(itemsJSON: itemsJSON)
                        self.deleteSizesWith(sizesJSON: sizesJSON)
                        self.deleteCategoriesWith(categoriesJSON: categoriesJSON)
                        self.deleteSchoolsWith(schoolsJSON: schoolsJSON)
                        
                        // Save context
                        do {
                            try self.context.save()
                        } catch {
                            let nserror = error as NSError
                            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                        }
                        
                        // Post notification
                        let notificationCenter = NotificationCenter.default
                        let notification = Notification(name: Notification.Name(rawValue: "apiPollDidFinish"))
                        notificationCenter.post(notification)
                    }
                }
            }
        }
    }
    
    // MARK: - Schools
    private func createSchoolsWith(schoolsJSON: [[String: Any]]) {
        
        for schoolJSON in schoolsJSON {
            
            guard let school = schoolJSON["school"] as? [String: Any] else {
                fatalError("Error getting school JSON")
            }
            guard let years = schoolJSON["years"] as? [[String: Any]] else {
                fatalError("Error getting school years JSON")
            }
            
            let timestampString = school["timestamp"] as! String
            guard let timestampDate = dateFormatter.date(from: timestampString) else {
                fatalError("Date conversion failed due to mismatched format")
            }
            
            var tempSchool: SUSchool?
            let id = UUID(uuidString: school["id"] as! String)!
            
            if let existingSchool = SUSchool.getObjectWithId(id) {
                
                if existingSchool.timestamp! < timestampDate {
                    
                    tempSchool = existingSchool
                    
                } else {
                 
                    create(years: years, forSchool: existingSchool)
                }
                
            } else {
                
                tempSchool = SUSchool(context: context)
                tempSchool!.id = id
            }
            
            if let tempSchool = tempSchool {
             
                tempSchool.schoolName = school["schoolName"] as? String
                tempSchool.sortOrder = school["sortOrder"] as! Int32
                tempSchool.timestamp = timestampDate
                
                create(years: years, forSchool: tempSchool)
            }
        }
    }
    
    // MARK: - Years
    private func create(years: [[String: Any]], forSchool school: SUSchool) {
        
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
                tempYear.school = school
            }
        }
    }
    
    // MARK: - Categories
    private func createCategoriesWith(categoriesJSON: [[String: Any]]) {
        
        for category in categoriesJSON {
            
            let timestampString = category["timestamp"] as! String
            guard let timestampDate = dateFormatter.date(from: timestampString) else {
                fatalError("Date conversion failed due to mismatched format")
            }
            
            var tempCategory: SUCategory?
            let id = UUID(uuidString: category["id"] as! String)!
            
            if let existingCategory = SUCategory.getObjectWithId(id) {
                
                if existingCategory.timestamp! < timestampDate {
                    
                    tempCategory = existingCategory
                }
                
            } else {
                
                tempCategory = SUCategory(context: context)
                tempCategory!.id = id
            }
            
            if let tempCategory = tempCategory {
             
                tempCategory.categoryName = category["categoryName"] as? String
                tempCategory.sortOrder = category["sortOrder"] as! Int32
                tempCategory.timestamp = timestampDate
            }
        }
    }
    
    // MARK: - Sizes
    private func createSizesWith(sizesJSON: [[String: Any]]) {
        
        for size in sizesJSON {
            
            let timestampString = size["timestamp"] as! String
            guard let timestampDate = dateFormatter.date(from: timestampString) else {
                fatalError("Date conversion failed due to mismatched format")
            }
            
            var tempSize: SUSize?
            let id = UUID(uuidString: size["id"] as! String)!
            
            if let existingSize = SUSize.getObjectWithId(id) {
                
                if existingSize.timestamp! < timestampDate {
                    
                    tempSize = existingSize
                }
                
            } else {
                
                tempSize = SUSize(context: context)
                tempSize!.id = id
                
            }
            
            if let tempSize = tempSize {
                
                tempSize.sizeName = size["sizeName"] as? String
                tempSize.sortOrder = size["sortOrder"] as! Int32
                tempSize.timestamp = timestampDate
            }
        }
    }
    
    // MARK: - Items
    private func createItemsWith(itemsJSON: [[String: Any]]) {
        
        for itemJSON in itemsJSON {
            
            guard let item = itemJSON["item"] as? [String : Any] else {
                fatalError("Failed to fetch item JSON")
            }
            guard let sizes = itemJSON["sizes"] as? [[String : Any]] else {
                fatalError("Failed to fetch item sizes JSON")
            }
            guard let years = itemJSON["years"] as? [[String : Any]] else {
                fatalError("Failed to fetch item years JSON")
            }
            guard let images = itemJSON["images"] as? [[String : Any]] else {
                fatalError("Failed to fetch item images JSON")
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
                    
                } else {
                    
                    create(sizes: sizes, forItem: existingItem)
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
                
                // Sizes
                create(sizes: sizes, forItem: tempItem)
            }
        }
    }
    
    // MARK: - Images
    private func deleteImagesForItem(_ id: UUID) {
        
        let fetchRequest: NSFetchRequest<SUImage> = SUImage.fetchRequest()
        let predicate = NSPredicate(format: "item.id == %@", id as CVarArg)
        fetchRequest.predicate = predicate
        
        do {
            
            let images = try context.fetch(fetchRequest)
                
            for image in images {
                
                context.delete(image)
            }
            
        } catch {
            
            let nserror = error as NSError
            print("Error deleting images for item with id \(id): \(nserror.userInfo)")
        }
    }
    
    // MARK: - Item Sizes
    private func create(sizes: [[String: Any]], forItem item: SUItem) {
        
        for itemSize in sizes {
            
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
