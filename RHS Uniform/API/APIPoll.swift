//
//  APIPolling.swift
//  RHS Uniform
//
//  Created by David Canty on 12/03/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import Foundation

class APIPoll {
    
    var apiController = APIController()
    var apiPollTimer: Timer?
    
    func startPolling() {
        
        apiPollTimer?.invalidate()
        
        fetchData()
        
        let apiPollInterval: TimeInterval = AppConfig.sharedInstance.apiPollInterval()
        apiPollTimer = Timer.scheduledTimer(timeInterval: apiPollInterval, target: self, selector: #selector(fetchData), userInfo: nil, repeats: true)
    }
    
    func stopPolling() {
        
        apiPollTimer?.invalidate()
    }
    
    @objc func fetchData() {
        
        apiController.fetchData()
    }
}
