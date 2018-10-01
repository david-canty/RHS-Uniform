//
//  Config.swift
//  RHS Uniform
//
//  Created by David Canty on 11/02/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import Foundation

final class AppConfig {
    
    static let sharedInstance = AppConfig()
    
    private let isDevMode = true
    
    private let baseDevUrlString = "http://localhost:8080/api"
    
    private let baseUrlString = "https://suapi.vapor.cloud/api"
    
    private let networkPollTimeInterval: TimeInterval = 300 // 5 minutes
    //private let apiPollTimeInterval: TimeInterval = 86400 // 24 hours
    private let apiPollTimeInterval: TimeInterval = 10
    
    private init() {}
    
    func isDevelopmentMode() -> Bool { return isDevMode }
    
    func baseUrlPath() -> String { return isDevMode ? baseDevUrlString : baseUrlString }
    
    func networkPollInterval() -> TimeInterval { return networkPollTimeInterval }
    
    func apiPollInterval() -> TimeInterval { return apiPollTimeInterval }
    
}
