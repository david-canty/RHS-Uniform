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
    
    static let shared = APIClient()
    
    private let context: NSManagedObjectContext!
    private let currentUser: User!
    private let dateFormatter: DateFormatter
    
    private init() {
        
        context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        currentUser = Auth.auth().currentUser
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    }
    
    // MARK: - Fetch data
    func fetchData() {
        
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        currentUser.getIDTokenForcingRefresh(true) { idToken, error in
            
            if let error = error {
                
                print("Error getting user ID token: \(error)")
                return
                
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
                        
                        self.fetchOrders { ordersJSON, error in
                            
                            if error != nil {
                                
                                print("Error fetching orders JSON: \(error!.localizedDescription)")
                                
                                DispatchQueue.main.async {
                                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                }
                                
                            } else {
                                
                                if let ordersJSON = ordersJSON {
                                
                                    self.createOrdersWith(ordersJSON: ordersJSON)
                                    self.deleteOrders(with: ordersJSON)
                            
                                    self.saveContextAndPostNotification()
                                    
                                    DispatchQueue.main.async {
                                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                    }
                                }
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                }
            }
        }
    }
    
    func fetchOrders(completion: @escaping ([[String: Any]]?, Error?) -> Void) {
        
        currentUser.getIDTokenForcingRefresh(true) { idToken, error in
            
            if let error = error {
                
                completion(nil, error)
                
            } else {
                
                if let token = idToken {
                    
                    guard let customer = SUCustomer.getObjectWithEmail(self.currentUser.email!), let customerId = customer.id?.uuidString else {
                        let error = APIClientError.error("Failed to get customer")
                        completion(nil, error)
                        return
                    }
                    
                    Alamofire.request(APIRouter.orders(userIdToken: token, customerId: customerId)).responseJSON { response in
                        
                        switch response.result {
                            
                        case .success:
                            
                            if let orders = response.result.value as? [[String: Any]] {
                                
                                completion(orders, nil)
                                
                            } else {
                                
                                let error = APIClientError.error("Failed to get orders")
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
    
    func saveContext() {
        
        do {
            try self.context.save()
        } catch {
            let nserror = error as NSError
            print("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    func saveContextAndPostNotification() {
        
        // Save context
        saveContext()
        
        // Post notification
        let notificationCenter = NotificationCenter.default
        let notification = Notification(name: Notification.Name(rawValue: "coreDataUpdatedFromAPI"))
        notificationCenter.post(notification)
    }
    
    // MARK: - Schools
    private func createSchoolsWith(schoolsJSON: [[String: Any]]) {
        
        schoolLoop: for schoolJSON in schoolsJSON {
            
            guard let school = schoolJSON["school"] as? [String: Any],
                let years = schoolJSON["years"] as? [[String: Any]] else {
                    
                print("Error getting school and years JSON")
                continue schoolLoop
            }
            
            let timestampString = school["timestamp"] as! String
            guard let timestampDate = dateFormatter.date(from: timestampString) else {
                print("Date conversion failed due to mismatched format")
                continue schoolLoop
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
        
        yearLoop: for year in years {
            
            let timestampString = year["timestamp"] as! String
            guard let timestampDate = dateFormatter.date(from: timestampString) else {
                print("Date conversion failed due to mismatched format")
                continue yearLoop
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
        
        categoryLoop: for category in categoriesJSON {
            
            let timestampString = category["timestamp"] as! String
            guard let timestampDate = dateFormatter.date(from: timestampString) else {
                print("Date conversion failed due to mismatched format")
                continue categoryLoop
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
        
        sizeLoop: for size in sizesJSON {
            
            let timestampString = size["timestamp"] as! String
            guard let timestampDate = dateFormatter.date(from: timestampString) else {
                print("Date conversion failed due to mismatched format")
                continue sizeLoop
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
        
        itemLoop: for itemJSON in itemsJSON {
            
            guard let item = itemJSON["item"] as? [String : Any] else {
                print("Failed to fetch item JSON")
                continue itemLoop
            }
            guard let sizes = itemJSON["sizes"] as? [[String : Any]] else {
                print("Failed to fetch item sizes JSON")
                continue itemLoop
            }
            guard let years = itemJSON["years"] as? [[String : Any]] else {
                print("Failed to fetch item years JSON")
                continue itemLoop
            }
            guard let images = itemJSON["images"] as? [[String : Any]] else {
                print("Failed to fetch item images JSON")
                continue itemLoop
            }
            
            let timestampString = item["timestamp"] as? String
            guard let timestampDate = dateFormatter.date(from: timestampString!) else {
                print("Failed to convert date due to mismatched format")
                continue itemLoop
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
                tempItem.itemStatus = item["itemStatus"] as? String
                tempItem.timestamp = timestampDate
                
                // Item category relationship
                let categoryId = UUID(uuidString: item["categoryID"] as! String)!
                if let category = SUCategory.getObjectWithId(categoryId) {
                    tempItem.category = category
                }
                
                // Item years relationships
                if let existingYearRelationships = tempItem.years {
                    tempItem.removeFromYears(existingYearRelationships)
                }
                
                for year in years {
                    
                    let yearId = UUID(uuidString: year["id"] as! String)!
                    
                    if let yearObject = SUYear.getObjectWithId(yearId) {
                        tempItem.addToYears(yearObject)
                    }
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
        
        sizeLoop: for itemSize in sizes {
            
            let timestampString = itemSize["timestamp"] as! String
            guard let timestampDate = dateFormatter.date(from: timestampString) else {
                print("Date conversion failed due to mismatched format")
                continue sizeLoop
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
                if let item = SUShopItem.getObjectWithId(itemId) {
                    newItemSize.item = item
                }
                
                
                let sizeId = UUID(uuidString: itemSize["sizeID"] as! String)!
                if let size = SUSize.getObjectWithId(sizeId) {
                    newItemSize.size = size
                }
            }
        }
    }
}

extension APIClient {
    
    // MARK: - Delete Items
    private func deleteItemsWith(itemsJSON: [[String: Any]]) {
        
        var itemIds = [UUID]()
        itemLoop: for itemJSON in itemsJSON {
            
            guard let item = itemJSON["item"] as? [String : Any] else {
                print("Error getting item JSON")
                continue itemLoop
            }
            guard let itemSizes = itemJSON["sizes"] as? [[String: Any]] else {
                print("Error getting item sizes JSON")
                continue itemLoop
            }
            guard let itemYears = itemJSON["years"] as? [[String: Any]] else {
                print("Error getting item years JSON")
                continue itemLoop
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
            
            print("Failed to fetch items for deletion: \(error)")
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
            
            print("Failed to fetch item sizes for deletion: \(error)")
        }
    }
    
    // MARK: - Delete Item Years
    private func deleteItemYearsWith(itemYearsJSON: [[String: Any]], forItemId itemId: UUID) {
        
        guard let itemObject = SUShopItem.getObjectWithId(itemId) else {
            print("Failed to get item with id \(itemId)")
            return
        }
        
        if let existingYearRelationships = itemObject.years {
            itemObject.removeFromYears(existingYearRelationships)
        }
        
        for itemYearJSON in itemYearsJSON {
            
            let yearId = UUID(uuidString: itemYearJSON["id"] as! String)!
            
            if let yearObject = SUYear.getObjectWithId(yearId)  {
                
                itemObject.addToYears(yearObject)
            }
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
            
            print("Failed to fetch sizes for deletion: \(error)")
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
            
            print("Failed to fetch categories for deletion: \(error)")
        }
    }
    
    // MARK: - Delete Schools
    private func deleteSchoolsWith(schoolsJSON: [[String: Any]]) {
        
        var schoolIds = [UUID]()
        schoolLoop: for schoolJSON in schoolsJSON {
            
            guard let school = schoolJSON["school"] as? [String: Any] else {
                print("Error getting school JSON")
                continue schoolLoop
            }
            guard let years = schoolJSON["years"] as? [[String: Any]] else {
                print("Error getting school years JSON")
                continue schoolLoop
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
            
            print("Failed to fetch schools for deletion: \(error)")
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
            
            print("Failed to fetch years for deletion: \(error)")
        }
    }
    
    // MARK: - Customers
    
    func createCustomer(withFirebaseId firebaseId: String, email: String, completion: @escaping ([String: Any]?, Error?) -> Void) {
        
        currentUser.getIDTokenForcingRefresh(true) { idToken, error in
            
            if let error = error {
                
                print("Error getting user ID token: \(error)")
                completion(nil, error)
                
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
    
    func save(apnsDeviceToken: String, completion: @escaping ([String: Any]?, Error?) -> Void) {
        
        currentUser.getIDTokenForcingRefresh(true) { idToken, error in
            
            if let error = error {
                
                print("Error getting user ID token: \(error)")
                completion(nil, error)
                
            } else {
                
                if let token = idToken {
                    
                    guard let customer = SUCustomer.getObjectWithEmail(self.currentUser.email!), let customerId = customer.id?.uuidString else {
                        let error = APIClientError.error("Failed to get customer")
                        completion(nil, error)
                        return
                    }
                    
                    Alamofire.request(APIRouter.customerAPNSDeviceToken(userIdToken: token, customerId: customerId, apnsDeviceToken: apnsDeviceToken)).responseJSON { response in
                        
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
    func createOrder(withOrderItems orderItems: [[String: Any]], paymentMethod: String, chargeId: String? = nil, completion: @escaping ([String: Any]?, Error?) -> Void) {
        
        currentUser.getIDTokenForcingRefresh(true) { idToken, error in
            
            if let error = error {
                
                print("Error getting user ID token: \(error)")
                completion(nil, error)
                
            } else {
                
                if let token = idToken {
                    
                    guard let customer = SUCustomer.getObjectWithEmail(self.currentUser.email!), let customerId = customer.id?.uuidString else {
                        let error = APIClientError.error("Failed to get customer")
                        completion(nil, error)
                        return
                    }
                    
                    Alamofire.request(APIRouter.orderCreate(userIdToken: token, customerId: customerId, orderItems: orderItems, paymentMethod: paymentMethod, chargeId: chargeId)).responseJSON { response in
                        
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
    
    private func createOrdersWith(ordersJSON: [[String: Any]]) {
        
        orderLoop: for orderJSON in ordersJSON {
            
            guard let order = orderJSON["order"] as? [String: Any] else {
                print("Error getting order JSON")
                continue orderLoop
            }
            guard let orderItemsWithActions = orderJSON["orderItemsWithActions"] as? [[String: Any]] else {
                print("Error getting order items and actions JSON")
                continue orderLoop
            }
            guard let customerId = order["customerID"] as? String else {
                print("Failed to get customer id from order JSON")
                continue orderLoop
            }
            guard let customer = SUCustomer.getObjectWithId(UUID(uuidString: customerId)!) else {
                print("Failed to get customer to create order")
                continue orderLoop
            }
            
            let timestampString = order["timestamp"] as! String
            guard let timestampDate = dateFormatter.date(from: timestampString) else {
                print("Date conversion failed due to mismatched format")
                continue orderLoop
            }
            
            var tempOrder: SUOrder?
            let id = Int32(order["id"] as! Int)
            
            if let existingOrder = SUOrder.getObjectWithId(id) {
                
                if existingOrder.timestamp! < timestampDate {
                    
                    tempOrder = existingOrder
                    
                } else {
                    
                    create(orderItemsAndActions: orderItemsWithActions, forOrder: existingOrder)
                }
                
            } else {
                
                tempOrder = SUOrder(context: context)
                tempOrder!.id = id
            }
            
            if let tempOrder = tempOrder {
                
                let orderDateString = order["orderDate"] as! String
                if let orderDate = dateFormatter.date(from: orderDateString) {
                    
                    tempOrder.orderDate = orderDate
                    tempOrder.orderStatus = order["orderStatus"] as? String
                    tempOrder.paymentMethod = order["paymentMethod"] as? String
                    tempOrder.timestamp = timestampDate
                    tempOrder.customer = customer
                    
                    create(orderItemsAndActions: orderItemsWithActions, forOrder: tempOrder)
                }
            }
        }
    }
    
    private func create(orderItemsAndActions orderItemsAndActionsJSON: [[String: Any]], forOrder order: SUOrder) {
        
        // Delete existing order items
        let fetchRequest: NSFetchRequest<SUOrderItem> = SUOrderItem.fetchRequest()
        let predicate = NSPredicate(format: "order.id == %i", order.id)
        fetchRequest.predicate = predicate

        do {

            let fetchedOrderItems = try context.fetch(fetchRequest)

            for fetchedOrderItem in fetchedOrderItems {
                context.delete(fetchedOrderItem)
            }

        } catch {

            print("Failed to fetch order items for deletion: \(error.localizedDescription)")
        }
        
        // Create order items
        orderItemLoop: for orderItemAndActionJSON in orderItemsAndActionsJSON {
            
            guard let orderItemJSON = orderItemAndActionJSON["orderItem"] as? [String: Any] else {
                print("Failed to get order item JSON")
                continue orderItemLoop
            }
            
            if let orderItem = createOrderItem(withData: orderItemJSON) {
            
                OrderItemActionIf: if let orderItemActionJSON = orderItemAndActionJSON["orderItemAction"] as? [String: Any] {
                    
                    guard let actionId = orderItemActionJSON["id"] as? String else {
                        print("Failed to get action id from order item JSON")
                        break OrderItemActionIf
                    }
                    guard let actionOrderItemId = orderItemActionJSON["orderItemID"] as? String else {
                        print("Failed to get action order item id from order item JSON")
                        break OrderItemActionIf
                    }
                    if actionOrderItemId != orderItem.id?.uuidString {
                        print("Invalid action order item id from order item JSON")
                        break OrderItemActionIf
                    }
                    guard let action = orderItemActionJSON["action"] as? String else {
                        print("Failed to get action from order item JSON")
                        break OrderItemActionIf
                    }
                    guard let actionQuantity = orderItemActionJSON["quantity"] as? Int32 else {
                        print("Failed to get action quantity from order item JSON")
                        break OrderItemActionIf
                    }
                    
                    let orderItemAction = SUOrderItemAction(context: context)
                    orderItemAction.id = UUID(uuidString: actionId)!
                    orderItemAction.action = action
                    orderItemAction.quantity = actionQuantity
                    orderItemAction.orderItem = orderItem
                }
            }
        }
    }
    
    func createOrderItem(withData data: [String: Any]) -> SUOrderItem? {
        
        guard let orderId = data["orderID"] as? Int32 else {
            print("Failed to get order id from order item data")
            return nil
        }
        guard let order = SUOrder.getObjectWithId(orderId) else {
            print("Failed to get order to create order item")
            return nil
        }
        guard let itemId = data["itemID"] as? String else {
            print("Failed to get item id from order item data")
            return nil
        }
        guard let item = SUShopItem.getObjectWithId(UUID(uuidString: itemId)!) else {
            print("Failed to get item to create order item")
            return nil
        }
        guard let sizeId = data["sizeID"] as? String else {
            print("Failed to get size id from order item data")
            return nil
        }
        guard let size = SUSize.getObjectWithId(UUID(uuidString: sizeId)!) else {
            print("Failed to get size to create order item")
            return nil
        }
        
        let orderItem = SUOrderItem(context: context)
        orderItem.id = UUID(uuidString: data["id"] as! String)!
        orderItem.quantity = data["quantity"] as! Int32
        orderItem.orderItemStatus = data["orderItemStatus"] as? String
        
        orderItem.order = order
        orderItem.item = item
        orderItem.size = size
        
        return orderItem
    }
    
    private func deleteOrders(with ordersJSON: [[String: Any]]) {
        
        var orderIds = [Int32]()
        for orderJSON in ordersJSON {
            
            guard let order = orderJSON["order"] as? [String: Any] else { return}
            guard let orderId = order["id"] as? Int else { return }
            orderIds.append(Int32(orderId))
        }
        
        let ordersFetchRequest: NSFetchRequest<SUOrder> = SUOrder.fetchRequest()
        let orderIdPredicate = NSPredicate(format: "NOT (id IN %@)", orderIds)
        ordersFetchRequest.predicate = orderIdPredicate
        
        do {
            
            let fetchedOrders = try self.context.fetch(ordersFetchRequest)
            
            for fetchedOrder in fetchedOrders {
                self.context.delete(fetchedOrder)
            }
            
        } catch {
            
            print("Failed to fetch orders for deletion: \(error.localizedDescription)")
        }
    }
    
    func fetchOrder(withId id: Int32, completion: @escaping (SUOrder?, Error?) -> Void) {
        
        currentUser.getIDTokenForcingRefresh(true) { idToken, error in
            
            if let error = error {
                
                print("Error getting user ID token: \(error)")
                completion(nil, error)
                
            } else {
                
                if let token = idToken {
                    
                    Alamofire.request(APIRouter.orderGet(userIdToken: token, orderId: id)).responseJSON { response in
                        
                        switch response.result {
                            
                        case .success:
                            
                            if let orderDetails = response.result.value as? [String: Any] {
                                
                                self.createOrdersWith(ordersJSON: [orderDetails])
                                self.saveContextAndPostNotification()
                                
                                if let order = SUOrder.getObjectWithId(id) {
                                    
                                    completion(order, nil)
                                    
                                } else {
                                    
                                    let error = APIClientError.error("Failed to get order")
                                    completion(nil, error)
                                }
                                
                            } else {
                                
                                let error = APIClientError.error("Failed to get order details")
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
    
    func cancel(orderId: Int32, completion: @escaping (SUOrder?, Error?) -> Void) {
        
        currentUser.getIDTokenForcingRefresh(true) { idToken, error in
            
            if let error = error {
                
                print("Error getting user ID token: \(error)")
                completion(nil, error)
                
            } else {
                
                if let token = idToken {
                    
                    Alamofire.request(APIRouter.orderCancel(userIdToken: token, orderId: orderId)).responseJSON { response in
                        
                        switch response.result {
                            
                        case .success:
                            
                            if let order = response.result.value as? [String: Any] {
                                
                                let orderId = order["id"] as! Int32
                                let orderStatus = order["orderStatus"] as! String
                                let timestampString = order["timestamp"] as! String
                                
                                guard let timestampDate = self.dateFormatter.date(from: timestampString) else {
                                    
                                    let error = APIClientError.error("Date conversion failed due to mismatched format")
                                    completion(nil, error)
                                    return
                                }
                                
                                if let updatedOrder = SUOrder.updateObjectWithId(orderId, withStatus: orderStatus, andTimestamp: timestampDate) {
                                    
                                    completion(updatedOrder, nil)
                                
                                } else {
                                
                                    let error = APIClientError.error("Failed to update order status to: \(orderStatus)")
                                    completion(nil, error)
                                }
                                
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
    
    func cancelReturn(orderItemId: UUID, action: String, quantity: Int, completion: @escaping (SUOrderItem?, SUOrderItemAction?, Error?) -> Void) {
        
        currentUser.getIDTokenForcingRefresh(true) { idToken, error in
            
            if let error = error {
                
                print("Error getting user ID token: \(error)")
                completion(nil, nil, error)
                
            } else {
                
                if let token = idToken {
                    
                    Alamofire.request(APIRouter.orderItemCancelReturn(userIdToken: token, orderItemId: orderItemId.uuidString, action: action, quantity: quantity)).responseJSON { response in
                        
                        switch response.result {
                            
                        case .success:
                            
                            if let orderItemData = response.result.value as? [String: Any] {
                                
                                guard let orderItem = orderItemData["orderItem"] as? [String: Any] else {
                                    let error = APIClientError.error("Failed to get order item data")
                                    completion(nil, nil, error)
                                    return
                                }
                                
                                guard let orderItemAction = orderItemData["orderItemAction"] as? [String: Any] else {
                                    let error = APIClientError.error("Failed to get order item action data")
                                    completion(nil, nil, error)
                                    return
                                }
                                
                                let orderItemId = UUID(uuidString: orderItem["id"] as! String)!
                                let orderItemStatus = orderItem["orderItemStatus"] as! String
                                
                                guard let updatedOrderItem = SUOrderItem.updateObjectWithId(orderItemId, withStatus: orderItemStatus) else {
                                    
                                    let error = APIClientError.error("Failed to update order item status to: \(orderItemStatus)")
                                    completion(nil, nil, error)
                                    return
                                }
                                
                                let apiActionId = UUID(uuidString: orderItemAction["id"] as! String)!
                                let apiAction = orderItemAction["action"] as! String
                                let apiActionQuantity = orderItemAction["quantity"] as! Int32
                                
                                let actionObject = SUOrderItemAction(context: self.context)
                                actionObject.id = apiActionId
                                actionObject.action = apiAction
                                actionObject.quantity = apiActionQuantity
                                actionObject.orderItem = updatedOrderItem
                                
                                self.saveContext()
                                
                                completion(updatedOrderItem, actionObject, nil)
                                
                            } else {
                                
                                let error = APIClientError.error("Failed to get order item and action data")
                                completion(nil, nil, error)
                            }
                            
                        case .failure(let error):
                            
                            completion(nil, nil, error)
                        }
                    }
                }
            }
        }
    }
    
    func fetchOrderItem(withId id: UUID, completion: @escaping (SUOrderItem?, Error?) -> Void) {
     
        currentUser.getIDTokenForcingRefresh(true) { idToken, error in
            
            if let error = error {
                
                print("Error getting user ID token: \(error)")
                completion(nil, error)
                
            } else {
                
                if let token = idToken {
                    
                    Alamofire.request(APIRouter.orderItemGet(userIdToken: token, orderItemId: id.uuidString)).responseJSON { response in
                        
                        switch response.result {
                            
                        case .success:
                            
                            if let orderItemData = response.result.value as? [String: Any] {
                                
                                if let oldOrderItem = SUOrderItem.getObjectWithId(id) {
                                    
                                    self.context.delete(oldOrderItem)
                                }
                                
                                if let newOrderItem = self.createOrderItem(withData: orderItemData) {
                                    
                                    self.saveContextAndPostNotification()
                                    completion(newOrderItem, nil)
                                    
                                } else {
                                 
                                    let error = APIClientError.error("Failed to create order item")
                                    completion(nil, error)
                                }
                                
                            } else {
                                
                                let error = APIClientError.error("Failed to get order item details")
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
