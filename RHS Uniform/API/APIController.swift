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
            
            let uniqueId = UUID(uuidString: school["id"] as! String)
            if let existingSchool = School.getObjectWithUniqueId(uniqueId!) {
                
                if existingSchool.timestamp! < timestampDate {
                    
                    existingSchool.schoolName = school["schoolName"] as? String
                    existingSchool.timestamp = timestampDate
                }
                
            } else {
                
                let newSchool = School(context: context)
                newSchool.uniqueId = uniqueId
                newSchool.schoolName = school["schoolName"] as? String
                newSchool.timestamp = timestampDate
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
            
            let uniqueId = UUID(uuidString: category["id"] as! String)
            if let existingCategory = UniformCategory.getObjectWithUniqueId(uniqueId!) {
                
                if existingCategory.timestamp! < timestampDate {
                    
                    existingCategory.categoryName = category["categoryName"] as? String
                    existingCategory.timestamp = timestampDate
                }
                
            } else {
                
                let newCategory = UniformCategory(context: context)
                newCategory.uniqueId = uniqueId
                newCategory.categoryName = category["categoryName"] as? String
                newCategory.timestamp = timestampDate
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
                        
                        if let json = response.result.value as? [String: Any] {
                            
                            let jsonData = json["data"] as! [String: Any]
                            let years = jsonData["years"] as! [[String: Any]]
                            
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
            
            var tempYear: UniformYear?
            
            let uniqueId = year["uniqueId"] as! Int32
            if let existingYear = UniformYear.getObjectWithUniqueId(uniqueId) {
                
                if existingYear.timestamp! < timestampDate {
                    
                    tempYear = existingYear
                }
                
            } else {
                
                tempYear = UniformYear(context: context)
                tempYear!.uniqueId = uniqueId
            }
            
            if tempYear != nil {
                
                // Year attributes
                tempYear!.yearName = year["yearName"] as? String
                tempYear!.timestamp = timestampDate
                
                // School relationship
                let school = year["school"] as! [String: Any]
                create(schools: [school])
                let schoolId = school["id"] as! UUID
                
                guard let schoolObject = School.getObjectWithUniqueId(schoolId) else {
                    fatalError("Failed to get school with unique id \(schoolId)")
                }
                
                tempYear!.school = schoolObject
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
                        
                        if let json = response.result.value as? [String: Any] {
                            
                            let jsonData = json["data"] as! [String: Any]
                            let sizes = jsonData["sizes"] as! [[String: Any]]
                            
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
            
            var sizeDict = [String: Any]()
            if let sizeAsDict = size["size"] as? [String: Any] {
                sizeDict = sizeAsDict
            } else {
                sizeDict = size
            }
            
            let timestampString = sizeDict["timestamp"] as! String
            guard let timestampDate = dateFormatter.date(from: timestampString) else {
                fatalError("Date conversion failed due to mismatched format")
            }
            
            let uniqueId = sizeDict["uniqueId"] as! Int32
            if let existingSize = UniformSize.getObjectWithUniqueId(uniqueId) {
                
                if existingSize.timestamp! < timestampDate {
                    
                    existingSize.sizeName = sizeDict["sizeName"] as? String
                    existingSize.timestamp = timestampDate
                }
                
            } else {
                
                let newSize = UniformSize(context: context)
                newSize.uniqueId = uniqueId
                newSize.sizeName = sizeDict["sizeName"] as? String
                newSize.timestamp = timestampDate
            }
        }
    }
    
    func fetchStocks() {
        
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            
            if let error = error {
                
                print("Error getting user ID token: \(error)")
                
            } else {
                
                if let token = idToken {
        
                    Alamofire.request(APIRouter.stocks(userIdToken: token)).responseJSON { response in
                        
                        if let json = response.result.value as? [String: Any] {
                            
                            let jsonData = json["data"] as! [String: Any]
                            let stocks = jsonData["stocks"] as! [[String: Any]]
                            
                            self.create(stocks: stocks)
                            
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
    
    private func create(stocks: [[String: Any]]) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        for stock in stocks {
            
            let timestampString = stock["timestamp"] as! String
            guard let timestampDate = dateFormatter.date(from: timestampString) else {
                fatalError("Date conversion failed due to mismatched format")
            }
            
            let uniqueId = stock["uniqueId"] as! Int32
            if let existingStock = UniformStock.getObjectWithUniqueId(uniqueId) {
                
                if existingStock.timestamp! < timestampDate {
                    
                    existingStock.stockLevel = stock["stockLevel"] as! Int32
                    existingStock.timestamp = timestampDate
                }
                
            } else {
                
                let newStock = UniformStock(context: context)
                newStock.uniqueId = uniqueId
                newStock.stockLevel = stock["stockLevel"] as! Int32
                newStock.timestamp = timestampDate
            }
        }
    }
    
    func fetchItems() {
        
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            
            if let error = error {
                
                print("Error getting user ID token: \(error)")
                
            } else {
                
                if let token = idToken {
        
                    Alamofire.request(APIRouter.items(userIdToken: token, categories: [], years: [], genders: [])).responseJSON { response in
                        
                        if let json = response.result.value as? [String: Any] {
                            
                            let jsonData = json["data"] as! [String: Any]
                            let items = jsonData["items"] as! [[String: Any]]
                            
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
        
        for item in items {
            
            let timestampString = item["timestamp"] as? String
            guard let timestampDate = dateFormatter.date(from: timestampString!) else {
                fatalError("Failed to convert date due to mismatched format")
            }
            
            var tempItem: UniformItem?
            
            let uniqueId = item["uniqueId"] as! Int32
            if let existingItem = UniformItem.getObjectWithUniqueId(uniqueId) {
                
                if existingItem.timestamp! < timestampDate {
                    
                    tempItem = existingItem
                }
                
            } else {
                
                tempItem = UniformItem(context: context)
                tempItem!.uniqueId = uniqueId
            }
            
            if tempItem != nil {
                
                // Item attributes
                tempItem!.itemName = item["itemName"] as? String
                tempItem!.itemDescription = item["itemDescription"] as? String
                tempItem!.itemColor = item["itemColor"] as? String
                tempItem!.itemGender = item["itemGender"] as? String
                tempItem!.itemPrice = item["itemPrice"] as! Double
                tempItem!.itemImage = item["itemImage"] as? String
                tempItem!.timestamp = timestampDate
                
                // Item category relationship
                let category = item["category"] as! [String: Any]
                create(categories: [category])
                let categoryId = UUID(uuidString: category["id"] as! String)
                
                guard let uniformCategory = UniformCategory.getObjectWithUniqueId(categoryId!) else {
                    fatalError("Failed to get category with unique id \(String(describing: categoryId))")
                }
                tempItem!.uniformCategory = uniformCategory
                
                // Item years relationships
                let years = item["years"] as! [[String: Any]]
                create(years: years)
                
                if let yearsRelationships = tempItem?.uniformYears {
                    tempItem?.removeFromUniformYears(yearsRelationships)
                }
                
                for year in years {
                    
                    let yearId = year["uniqueId"] as! Int32
                    
                    guard let uniformYear = UniformYear.getObjectWithUniqueId(yearId) else {
                        fatalError("Failed to get year with unique id \(yearId)")
                    }
                    tempItem!.addToUniformYears(uniformYear)
                }
                
                // Item stocks and sizes relationships
                let sizes = item["sizes"] as! [[String: Any]]
                
                create(sizes: sizes)
                create(stocks: sizes)
                
                if let stocksRelationships = tempItem?.uniformStocks {
                    tempItem?.removeFromUniformStocks(stocksRelationships)
                }
                
                for stock in sizes {
                    
                    let stockId = stock["uniqueId"] as! Int32
                    guard let uniformStock = UniformStock.getObjectWithUniqueId(stockId) else {
                        fatalError("Failed to get stock with unique id \(stockId)")
                    }
                    tempItem!.addToUniformStocks(uniformStock)
                    
                    let size = stock["size"] as! [String: Any]
                    let sizeId = size["uniqueId"] as! Int32
                    guard let uniformSize = UniformSize.getObjectWithUniqueId(sizeId) else {
                        fatalError("Failed to get size with unique id \(stockId)")
                    }
                    uniformStock.uniformSize = uniformSize
                }
            }
        }
    }
    
}
