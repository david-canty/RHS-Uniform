//
//  APIPolling.swift
//  RHS Uniform
//
//  Created by David Canty on 12/03/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import Foundation

class APIPoll {
    
    var apiController: APIController!
    var apiPollTimer: Timer?
    
    init() {
        apiController = APIController()
    }
    
    func startPolling() {
        
        fetchData()
        
        apiPollTimer?.invalidate()
        let apiPollInterval: TimeInterval = AppConfig.sharedInstance.apiPollInterval()
        apiPollTimer = Timer.scheduledTimer(timeInterval: apiPollInterval, target: self, selector: #selector(pollAPI), userInfo: nil, repeats: true)
    }
    
    func stopPolling() {
        
        apiPollTimer?.invalidate()
    }
    
    @objc func pollAPI() {
        
        fetchData()
    }
    
    func fetchData() {
        
        let queue = DispatchQueue(label: "fetchApiDispatchGroup",
                                  attributes: .concurrent,
                                  target: .main)
        let group = DispatchGroup()
        
        queue.async (group: group) {
            self.apiController.fetchSchools()
        }
        
        queue.async (group: group) {
            self.apiController.fetchYears()
        }
        
        queue.async (group: group) {
            self.apiController.fetchCategories()
        }
        
        queue.async (group: group) {
            self.apiController.fetchSizes()
        }
        
        queue.async (group: group) {
            self.apiController.fetchItems()
        }
        
        queue.async (group: group) {
            self.apiController.fetchStocks()
        }
        
        queue.async (group: group) {
            self.apiController.purgeDeletedApiItems()
        }
        
        group.notify(queue: DispatchQueue.main) {
            
            let notificationCenter = NotificationCenter.default
            let notification = Notification(name: Notification.Name(rawValue: "apiPollDidFinish"))
            notificationCenter.post(notification)
        }
    }
}
