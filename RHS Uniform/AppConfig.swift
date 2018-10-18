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
    
    private let baseUrlString = "https://su-api.v2.vapor.cloud/api"
    
    private let s3BucketUrlString = "https://s3.eu-west-2.amazonaws.com/su-api-rhs"
    
    private let networkPollTimeInterval: TimeInterval = 300 // 5 minutes
    //private let apiPollTimeInterval: TimeInterval = 86400 // 24 hours
    private let apiPollTimeInterval: TimeInterval = 10
    
    private init() {}
    
    func isDevelopmentMode() -> Bool { return isDevMode }
    
    func baseUrlPath() -> String { return isDevMode ? baseDevUrlString : baseUrlString }
    
    func s3BucketUrlPath() -> String { return s3BucketUrlString }
    
    func networkPollInterval() -> TimeInterval { return networkPollTimeInterval }
    
    func apiPollInterval() -> TimeInterval { return apiPollTimeInterval }
    
}
