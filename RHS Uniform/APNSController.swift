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
            
            let orderId = orderIdDict["orderId"] as? String
            print(orderId)
        }
    }
    
    func updateOrder(withId id: Int32) {
        
        
    }
}
