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
        
        // Order
        if let orderIdDict = dict(forKey: "orderId", inDict: custom) {
            
            if let orderId = orderIdDict["orderId"] as? String,
                let id = Int32(orderId) {
                
                fetchOrder(withId: id)
            }
        }
        
        // Order item
        if let orderItemIdDict = dict(forKey: "orderItemId", inDict: custom) {
            
            if let orderItemId = orderItemIdDict["orderItemId"] as? String,
                let id = UUID(uuidString: orderItemId) {
                
                fetchOrderItem(withId: id)
            }
        }
    }
    
    func dict(forKey key: String, inDict dict: [String: Any]) -> [String: Any]? {
        
        return dict.first {
            
            if let valueAsDict = $1 as? [String: Any] {
                return valueAsDict.index(forKey: key) != nil
            }
            
            return false
            
        }?.value as? [String: Any]
    }
    
    func fetchOrder(withId id: Int32) {
        
        APIClient.shared.fetchOrder(withId: id) { (order, error) in
            
            if let error = error as NSError? {
                
                print("Error fetching order with id \(id): \(error.localizedDescription)")
            }
        }
    }
    
    func fetchOrderItem(withId id: UUID) {
        
        APIClient.shared.fetchOrderItem(withId: id) { (orderItem, error) in
            
            if let error = error as NSError? {
                
                print("Error fetching order item with id \(id): \(error.localizedDescription)")
            }
        }
    }
}
