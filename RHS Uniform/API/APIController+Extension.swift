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
        
                    Alamofire.request(APIRouter.items(userIdToken: token, categories: [], years: [], genders: [])).responseJSON { response in
                        
                        if let json = response.result.value as? [String: Any] {
                            
                            let jsonData = json["data"] as! [String: Any]
                            let items = jsonData["items"] as! [[String: Any]]
                            
                            var apiItemIds = [Int32]()
                            for item in items {
                            
                                apiItemIds.append(item["uniqueId"] as! Int32)
                            }
                            
                            let itemsFetchRequest: NSFetchRequest<UniformItem> = UniformItem.fetchRequest()
                            
                            do {
                                
                                let fetchedItems = try self.context.fetch(itemsFetchRequest)
                                
                                for fetchedItem in fetchedItems {
                                    
                                    if !apiItemIds.contains(fetchedItem.uniqueId) {

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
                                
                            } catch {
                                
                                fatalError("Failed to fetch uniform items for deletion: \(error)")
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
                        
                        if let json = response.result.value as? [String: Any] {
                            
                            let jsonData = json["data"] as! [String: Any]
                            let categories = jsonData["categories"] as! [[String: Any]]
                            
                            var apiCategoryIds = [UUID]()
                            for category in categories {
                                
                                apiCategoryIds.append(category["uniqueId"] as! UUID)
                            }
                            
                            let categoriesFetchRequest: NSFetchRequest<UniformCategory> = UniformCategory.fetchRequest()
                            
                            do {
                                
                                let fetchedCategories = try self.context.fetch(categoriesFetchRequest)
                                
                                for fetchedCategory in fetchedCategories {
                                    
                                    if !apiCategoryIds.contains(fetchedCategory.uniqueId!) {
                                        
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
                                
                                fatalError("Failed to fetch uniform categories for deletion: \(error)")
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
                        
                        if let json = response.result.value as? [String: Any] {
                            
                            let jsonData = json["data"] as! [String: Any]
                            let years = jsonData["years"] as! [[String: Any]]
                            
                            var apiYearIds = [Int32]()
                            for year in years {
                                
                                apiYearIds.append(year["uniqueId"] as! Int32)
                            }
                            
                            let yearsFetchRequest: NSFetchRequest<UniformYear> = UniformYear.fetchRequest()
                            
                            do {
                                
                                let fetchedYears = try self.context.fetch(yearsFetchRequest)
                                
                                for fetchedYear in fetchedYears {
                                    
                                    if !apiYearIds.contains(fetchedYear.uniqueId) {
                                        
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
                                
                                fatalError("Failed to fetch uniform years for deletion: \(error)")
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
                        
                        if let json = response.result.value as? [String: Any] {
                            
                            let jsonData = json["data"] as! [String: Any]
                            let schools = jsonData["schools"] as! [[String: Any]]
                            
                            var apiSchoolIds = [UUID]()
                            for school in schools {
                                
                                apiSchoolIds.append(school["uniqueId"] as! UUID)
                            }
                            
                            let schoolsFetchRequest: NSFetchRequest<School> = School.fetchRequest()
                            
                            do {
                                
                                let fetchedSchools = try self.context.fetch(schoolsFetchRequest)
                                
                                for fetchedSchool in fetchedSchools {
                                    
                                    if !apiSchoolIds.contains(fetchedSchool.uniqueId!) {
                                        
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
                        
                        if let json = response.result.value as? [String: Any] {
                            
                            let jsonData = json["data"] as! [String: Any]
                            let sizes = jsonData["sizes"] as! [[String: Any]]
                            
                            var apiSizeIds = [Int32]()
                            for size in sizes {
                                
                                apiSizeIds.append(size["uniqueId"] as! Int32)
                            }
                            
                            let sizesFetchRequest: NSFetchRequest<UniformSize> = UniformSize.fetchRequest()
                            
                            do {
                                
                                let fetchedSizes = try self.context.fetch(sizesFetchRequest)
                                
                                for fetchedSize in fetchedSizes {
                                    
                                    if !apiSizeIds.contains(fetchedSize.uniqueId) {
                                        
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
                                
                                fatalError("Failed to fetch uniform sizes for deletion: \(error)")
                            }
                        }
                    }
                }
            }
        }
    }
    
}
