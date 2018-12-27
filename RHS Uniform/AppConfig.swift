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
    
    private let stripeCurrency = "gbp"
    private let stripeDescription = "Order from RHS Uniform app"
    
    private let s3BucketUrlStr = "https://s3.eu-west-2.amazonaws.com/su-api-rhs"
    
    private let networkPollTimeInterval: TimeInterval = 300 // 5 minutes
    //private let apiPollTimeInterval: TimeInterval = 86400 // 24 hours
    private let apiPollTimeInterval: TimeInterval = 10
    
    private init() {}
    
    func baseUrlString() -> String {
        guard let baseUrlString = configValueForKey("Base URL String") else {
            fatalError("Failed to get base URL string")
        }
        return baseUrlString
    }
    
    func stripePublishableKey() -> String {
        guard let stripePublishableKey = configValueForKey("Stripe Publishable Key") else {
            fatalError("Failed to get Stripe publishable key")
        }
        return stripePublishableKey
    }
    
    func stripeChargeCurrency() -> String { return stripeCurrency }
    
    func stripeChargeDescription() -> String { return stripeDescription }
    
    func s3BucketUrlString() -> String { return s3BucketUrlStr }
    
    func oneSignalAppID() -> String {
        guard let oneSignalAppID = configValueForKey("OneSignal App ID") else {
            fatalError("Failed to get OneSignal app ID")
        }
        return oneSignalAppID
    }
    
    func networkPollInterval() -> TimeInterval { return networkPollTimeInterval }
    
    func apiPollInterval() -> TimeInterval { return apiPollTimeInterval }
    
    private func configValueForKey(_ key: String) -> String? {
        return (Bundle.main.infoDictionary?[key] as? String)?
            .replacingOccurrences(of: "\\", with: "")
    }
}
