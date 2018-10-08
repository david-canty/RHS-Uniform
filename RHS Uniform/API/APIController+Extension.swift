//
//  APIController+Extension.swift
//  RHS Uniform
//
//  Created by David Canty on 23/02/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import Foundation
import CoreData
import Alamofire

extension APIController {

    func purgeDeletedApiItems() {
        
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            
            if let error = error {
                
                print("Error getting user ID token: \(error)")
                
            } else {
                
                if let token = idToken {
        
                    Alamofire.request(APIRouter.items(userIdToken: token)).responseJSON { response in
                        
                        if let itemsWithRelations = response.result.value as? [[String: Any]] {
                            
                            var apiItemIds = [UUID]()
                            for itemWithRelations in itemsWithRelations {
                            
                                guard let item = itemWithRelations["item"] as? [String : Any] else {
                                    fatalError("Failed to fetch item data")
                                }
                                let itemId = UUID(uuidString: item["id"] as! String)!
                                apiItemIds.append(itemId)
                            }
                            
                            let itemsFetchRequest: NSFetchRequest<SUItem> = SUItem.fetchRequest()
                            
                            do {
                                
                                let fetchedItems = try self.context.fetch(itemsFetchRequest)
                                
                                for fetchedItem in fetchedItems {
                                    
                                    if !apiItemIds.contains(fetchedItem.id!) {

                                        self.context.delete(fetchedItem)
                                    }
                                }
                                
                                do {
                                    try self.context.save()
                                } catch {
                                    let nserror = error as NSError
                                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                                }
                                
                                self.purgeDeletedApiCategories()
                                self.purgeDeletedApiYears()
                                self.purgeDeletedApiSchools()
                                self.purgeDeletedApiSizes()
                                self.purgeDeletedApiItemSizes()
                                
                            } catch {
                                
                                fatalError("Failed to fetch items for deletion: \(error)")
                            }
                        }
                    }
                }
            }
        }
    }
    
    func purgeDeletedApiCategories() {
        
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            
            if let error = error {
                
                print("Error getting user ID token: \(error)")
                
            } else {
                
                if let token = idToken {
        
                    Alamofire.request(APIRouter.categories(userIdToken: token)).responseJSON { response in
                        
                        if let categories = response.result.value as? [[String: Any]] {
                            
                            var apiCategoryIds = [UUID]()
                            for category in categories {
                                
                                let categoryId = UUID(uuidString: category["id"] as! String)!
                                apiCategoryIds.append(categoryId)
                            }
                            
                            let categoriesFetchRequest: NSFetchRequest<SUCategory> = SUCategory.fetchRequest()
                            
                            do {
                                
                                let fetchedCategories = try self.context.fetch(categoriesFetchRequest)
                                
                                for fetchedCategory in fetchedCategories {
                                    
                                    if !apiCategoryIds.contains(fetchedCategory.id!) {
                                        
                                        self.context.delete(fetchedCategory)
                                    }
                                }
                                
                                do {
                                    try self.context.save()
                                } catch {
                                    let nserror = error as NSError
                                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                                }
                                
                            } catch {
                                
                                fatalError("Failed to fetch categories for deletion: \(error)")
                            }
                        }
                    }
                }
            }
        }
    }
    
    func purgeDeletedApiYears() {
        
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            
            if let error = error {
                
                print("Error getting user ID token: \(error)")
                
            } else {
                
                if let token = idToken {
        
                    Alamofire.request(APIRouter.years(userIdToken: token)).responseJSON { response in
                        
                        if let years = response.result.value as? [[String: Any]] {
                            
                            var apiYearIds = [UUID]()
                            for year in years {
                                
                                let yearId = UUID(uuidString: year["id"] as! String)!
                                apiYearIds.append(yearId)
                            }
                            
                            let yearsFetchRequest: NSFetchRequest<SUYear> = SUYear.fetchRequest()
                            
                            do {
                                
                                let fetchedYears = try self.context.fetch(yearsFetchRequest)
                                
                                for fetchedYear in fetchedYears {
                                    
                                    if !apiYearIds.contains(fetchedYear.id!) {
                                        
                                        self.context.delete(fetchedYear)
                                    }
                                }
                                
                                do {
                                    try self.context.save()
                                } catch {
                                    let nserror = error as NSError
                                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                                }
                                
                            } catch {
                                
                                fatalError("Failed to fetch years for deletion: \(error)")
                            }
                        }
                    }
                }
            }
        }
    }
    
    func purgeDeletedApiSchools() {
        
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            
            if let error = error {
                
                print("Error getting user ID token: \(error)")
                
            } else {
                
                if let token = idToken {
        
                    Alamofire.request(APIRouter.schools(userIdToken: token)).responseJSON { response in
                        
                        if let schools = response.result.value as? [[String: Any]] {
                            
                            var apiSchoolIds = [UUID]()
                            for school in schools {
                                
                                let schoolId = UUID(uuidString: school["id"] as! String)!
                                apiSchoolIds.append(schoolId)
                            }
                            
                            let schoolsFetchRequest: NSFetchRequest<SUSchool> = SUSchool.fetchRequest()
                            
                            do {
                                
                                let fetchedSchools = try self.context.fetch(schoolsFetchRequest)
                                
                                for fetchedSchool in fetchedSchools {
                                    
                                    if !apiSchoolIds.contains(fetchedSchool.id!) {
                                        
                                        self.context.delete(fetchedSchool)
                                    }
                                }
                                
                                do {
                                    try self.context.save()
                                } catch {
                                    let nserror = error as NSError
                                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                                }
                                
                            } catch {
                                
                                fatalError("Failed to fetch schools for deletion: \(error)")
                            }
                        }
                    }
                }
            }
        }
    }
    
    func purgeDeletedApiSizes() {
        
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            
            if let error = error {
                
                print("Error getting user ID token: \(error)")
                
            } else {
                
                if let token = idToken {
        
                    Alamofire.request(APIRouter.sizes(userIdToken: token)).responseJSON { response in
                        
                        if let sizes = response.result.value as? [[String: Any]] {
                            
                            var apiSizeIds = [UUID]()
                            for size in sizes {
                                
                                let sizeId = UUID(uuidString: size["id"] as! String)!
                                apiSizeIds.append(sizeId)
                            }
                            
                            let sizesFetchRequest: NSFetchRequest<SUSize> = SUSize.fetchRequest()
                            
                            do {
                                
                                let fetchedSizes = try self.context.fetch(sizesFetchRequest)
                                
                                for fetchedSize in fetchedSizes {
                                    
                                    if !apiSizeIds.contains(fetchedSize.id!) {
                                        
                                        self.context.delete(fetchedSize)
                                    }
                                }
                                
                                do {
                                    try self.context.save()
                                } catch {
                                    let nserror = error as NSError
                                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                                }
                                
                            } catch {
                                
                                fatalError("Failed to fetch sizes for deletion: \(error)")
                            }
                        }
                    }
                }
            }
        }
    }
    
    func purgeDeletedApiItemSizes() {
        
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            
            if let error = error {
                
                print("Error getting user ID token: \(error)")
                
            } else {
                
                if let token = idToken {
                    
                    Alamofire.request(APIRouter.itemSizes(userIdToken: token)).responseJSON { response in
                        
                        if let itemSizes = response.result.value as? [[String: Any]] {
                            
                            var apiItemSizeIds = [UUID]()
                            for itemSize in itemSizes {
                                
                                let itemSizeId = UUID(uuidString: itemSize["id"] as! String)!
                                apiItemSizeIds.append(itemSizeId)
                            }
                            
                            let itemSizesFetchRequest: NSFetchRequest<SUItemSize> = SUItemSize.fetchRequest()
                            
                            do {
                                
                                let fetchedItemSizes = try self.context.fetch(itemSizesFetchRequest)
                                
                                for fetchedItemSize in fetchedItemSizes {
                                    
                                    if !apiItemSizeIds.contains(fetchedItemSize.id!) {
                                        
                                        self.context.delete(fetchedItemSize)
                                    }
                                }
                                
                                do {
                                    try self.context.save()
                                } catch {
                                    let nserror = error as NSError
                                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                                }
                                
                            } catch {
                                
                                fatalError("Failed to fetch item sizes for deletion: \(error)")
                            }
                        }
                    }
                }
            }
        }
    }
    
}
