//
//  APIClient.swift
//  RHS Uniform
//
//  Created by David Canty on 11/02/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import Foundation
import CoreData
import Alamofire
import FirebaseAuth

enum APIClientError: Error {
    case error(String)
}

final class APIClient {
    
    static let sharedInstance = APIClient()
    
    private let context: NSManagedObjectContext!
    private let currentUser: User!
    private let dateFormatter: DateFormatter
    
    private init() {
        
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
            
            var tempItem: SUShopItem?
            let id = UUID(uuidString: item["id"] as! String)!
            
            if let existingItem = SUShopItem.getObjectWithId(id) {
                
                if existingItem.timestamp! < timestampDate {
                    
                    tempItem = existingItem
                    
                } else {
                    
                    create(sizes: sizes, forItem: existingItem)
                }
                
            } else {
                
                tempItem = SUShopItem(context: context)
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
    private func create(sizes: [[String: Any]], forItem item: SUShopItem) {
        
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
                guard let item = SUShopItem.getObjectWithId(itemId) else {
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

extension APIClient {
    
    // MARK: - Delete Items
    private func deleteItemsWith(itemsJSON: [[String: Any]]) {
        
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
    
    // MARK: - Delete Item Sizes
    private func deleteItemSizesWith(itemSizesJSON: [[String: Any]], forItemId itemId: UUID) {
        
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
    
    // MARK: - Delete Item Years
    private func deleteItemYearsWith(itemYearsJSON: [[String: Any]], forItemId itemId: UUID) {
        
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
    
    // MARK: - Delete Sizes
    private func deleteSizesWith(sizesJSON: [[String: Any]]) {
        
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
    
    // MARK: - Delete Categories
    private func deleteCategoriesWith(categoriesJSON: [[String: Any]]) {
        
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
    
    // MARK: - Delete Schools
    private func deleteSchoolsWith(schoolsJSON: [[String: Any]]) {
        
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
    
    // MARK: - Delete Years
    private func deleteYearsWith(yearsJSON: [[String: Any]], forSchoolId schoolId: UUID) {
        
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
    
    // MARK: - Customers
    
    func createCustomer(withFirebaseId firebaseId: String, email: String, completion: @escaping ([String: Any]?, Error?) -> Void) {
        
        currentUser.getIDTokenForcingRefresh(true) { idToken, error in
            
            if let error = error {
                
                fatalError("Error getting user ID token: \(error)")
                
            } else {
                
                if let token = idToken {
                    
                    Alamofire.request(APIRouter.customerCreate(userIdToken: token, firebaseUserId: firebaseId, email: email)).responseJSON { response in
                        
                        switch response.result {
                            
                        case .success:
                            
                            if let customer = response.result.value as? [String: Any] {
                                
                                completion(customer, nil)
                                
                            } else {
                             
                                let error = APIClientError.error("Failed to get customer data")
                                completion(nil, error)
                            }
                            
                        case .failure(let error):
                            completion(nil, error)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Orders
    func createOrder(withOrderItems orderItems: [[String: Any]], paymentMethod: String, completion: @escaping ([String: Any]?, Error?) -> Void) {
        
        currentUser.getIDTokenForcingRefresh(true) { idToken, error in
            
            if let error = error {
                
                fatalError("Error getting user ID token: \(error)")
                
            } else {
                
                if let token = idToken {
                    
                    guard let customer = SUCustomer.getObjectWithEmail(self.currentUser.email!), let customerId = customer.id?.uuidString else {
                        let error = APIClientError.error("Failed to get customer")
                        completion(nil, error)
                        return
                    }
                    
                    Alamofire.request(APIRouter.orderCreate(userIdToken: token, customerId: customerId, orderItems: orderItems, paymentMethod: paymentMethod)).responseJSON { response in
                        
                        switch response.result {
                            
                        case .success:
                            
                            if let order = response.result.value as? [String: Any] {
                                
                                completion(order, nil)
                                
                            } else {
                                
                                let error = APIClientError.error("Failed to get order data")
                                completion(nil, error)
                            }
                            
                        case .failure(let error):
                            completion(nil, error)
                        }
                    }
                }
            }
        }
    }
}
