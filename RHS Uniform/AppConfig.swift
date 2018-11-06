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
    
    private let baseDevUrlStr = "http://localhost:8080/api"
    private let baseUrlStr = "https://su-api.v2.vapor.cloud/api"
    private let s3BucketUrlStr = "https://s3.eu-west-2.amazonaws.com/su-api-rhs"
    
    private let networkPollTimeInterval: TimeInterval = 300 // 5 minutes
    //private let apiPollTimeInterval: TimeInterval = 86400 // 24 hours
    private let apiPollTimeInterval: TimeInterval = 10
    
    private let stripeTestPublishableKey = ProcessInfo.processInfo.environment["STRIPE_TEST_PUBLISHABLE_KEY"]!
    private let stripeLivePublishableKey = ProcessInfo.processInfo.environment["STRIPE_LIVE_PUBLISHABLE_KEY"]!
    private let stripeCurrency = "gbp"
    private let stripeDescription = "Order from RHS Uniform app"
    
    private init() {}
    
    func isDevelopmentMode() -> Bool { return isDevMode }
    
    func baseUrlString() -> String { return isDevMode ? baseDevUrlStr : baseUrlStr }
    
    func s3BucketUrlString() -> String { return s3BucketUrlStr }
    
    func networkPollInterval() -> TimeInterval { return networkPollTimeInterval }
    
    func apiPollInterval() -> TimeInterval { return apiPollTimeInterval }
    
    func stripePublishableKey() -> String {
        return isDevMode ? stripeTestPublishableKey : stripeLivePublishableKey
    }
    
    func stripeChargeCurrency() -> String {
        return stripeCurrency
    }
    
    func stripeChargeDescription() -> String {
        return stripeDescription
    }
}
