//
//  APNSController.swift
//  RHS Uniform
//
//  Created by David Canty on 30/12/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import Foundation

final class APNSController {
    
    static let shared = APNSController()
    
    private init() {}
    
    func handleNotification(withAPS aps: [String: Any], andCustom custom: [String: Any]) {
        
        if let orderIdDict = (custom.first {
            
            if let valueAsDict = $1 as? [String: Any] {
                return valueAsDict.index(forKey: "orderId") != nil
            }
            
            return false
            
        }?.value) as? [String: Any] {
            
            if let orderId = orderIdDict["orderId"] as? String,
                let id = Int32(orderId) {
                
                updateOrder(withId: id)
            }
        }
    }
    
    func updateOrder(withId id: Int32) {
        
        APIClient.shared.fetchOrder(withId: id) { (order, error) in
            
            if let error = error as NSError? {
                
                print("Error fetching order with id \(id): \(error.localizedDescription)")
            }
        }
    }
}
