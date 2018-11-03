//
//  StripeClient.swift
//  RHS Uniform
//
//  Created by David Canty on 24/10/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import Foundation
import Stripe
import Alamofire
import FirebaseAuth

enum Result {
    case success
    case failure(Error)
}

final class StripeClient: NSObject, STPEphemeralKeyProvider {
    
    static let sharedInstance = StripeClient()
    
    override private init() {}
    
    private lazy var baseURL: URL = {
        guard let url = URL(string: AppConfig.sharedInstance.baseUrlString()) else {
            fatalError("Invalid base URL")
        }
        return url
    }()

    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        
        guard let currentUser = Auth.auth().currentUser else { return }
        
        currentUser.getIDTokenForcingRefresh(true) { idToken, error in
            
            if let error = error {
                
                fatalError("Error getting user ID token: \(error)")
                
            } else {
                
                if let userIdToken = idToken {
                    
                    if let customerId = KeychainController.readItem(withAccountName: "StripeCustomerId") {
                        
                        Alamofire.request(APIRouter.stripeEphemeralKey(userIdToken: userIdToken, customerId: customerId, apiVersion: apiVersion))
                            .validate(statusCode: 200..<300)
                            .responseJSON { responseJSON in
                                
                                switch responseJSON.result {
                                case .success(let json):
                                    completion(json as? [String: AnyObject], nil)
                                case .failure(let error):
                                    completion(nil, error)
                                }
                        }
                    }
                }
            }
        }
    }
    
    func createCustomer(withEmail email: String, completion: @escaping (Result) -> Void) {
        
        guard let currentUser = Auth.auth().currentUser else { return }
        
        currentUser.getIDTokenForcingRefresh(true) { idToken, error in
            
            if let error = error {
                
                fatalError("Error getting user ID token: \(error)")
                
            } else {
                
                if let userIdToken = idToken {
                    
                    if let customerId = KeychainController.readItem(withAccountName: "StripeCustomerId") {
                     
                        Alamofire.request(APIRouter.stripeCustomerGet(userIdToken: userIdToken, customerId: customerId))
                            .validate(statusCode: 200..<300)
                            .responseJSON { responseJSON in
                                
                                switch responseJSON.result {
                                case .success:
                                    completion(Result.success)
                                case .failure(let error):
                                    completion(Result.failure(error))
                                }
                        }
                        
                    } else {
                    
                        Alamofire.request(APIRouter.stripeCustomerCreate(userIdToken: userIdToken, email: email))
                            .validate(statusCode: 200..<300)
                            .responseJSON { response in
                                
                                switch response.result {
                                    
                                case .success:
                                    
                                    if let customer = response.result.value as? [String: Any] {
                                        
                                        let customerId = customer["id"] as! String
                                        KeychainController.save(item: customerId, withAccountName: "StripeCustomerId")
                                        
                                    } else {
                                        
                                        print("Failed to get Stripe customer id")
                                    }
                                    
                                    completion(Result.success)
                                    
                                case .failure(let error):
                                    completion(Result.failure(error))
                                }
                        }
                    }
                }
            }
        }
    }
    
    func getCustomer(withId customerId: String, completion: @escaping STPJSONResponseCompletionBlock) {
        
        guard let currentUser = Auth.auth().currentUser else { return }
        
        currentUser.getIDTokenForcingRefresh(true) { idToken, error in
            
            if let error = error {
                
                fatalError("Error getting user ID token: \(error)")
                
            } else {
                
                if let userIdToken = idToken {
                        
                    Alamofire.request(APIRouter.stripeCustomerGet(userIdToken: userIdToken, customerId: customerId))
                        .validate(statusCode: 200..<300)
                        .responseJSON { responseJSON in
                            
                            switch responseJSON.result {
                            case .success(let json):
                                completion(json as? [String: AnyObject], nil)
                            case .failure(let error):
                                completion(nil, error)
                            }
                    }
                }
            }
        }
    }
    
    func createCustomerSource(_ source: String, completion: @escaping STPJSONResponseCompletionBlock) {
        
        guard let currentUser = Auth.auth().currentUser else { return }
        
        currentUser.getIDTokenForcingRefresh(true) { idToken, error in
            
            if let error = error {
                
                fatalError("Error getting user ID token: \(error)")
                
            } else {
                
                if let userIdToken = idToken {
                    
                    if let customerId = KeychainController.readItem(withAccountName: "StripeCustomerId") {
                        
                        Alamofire.request(APIRouter.stripeCustomerSourceCreate(userIdToken: userIdToken, customerId: customerId, source: source))
                            .validate(statusCode: 200..<300)
                            .responseJSON { responseJSON in
                                
                                switch responseJSON.result {
                                case .success(let json):
                                    completion(json as? [String: AnyObject], nil)
                                case .failure(let error):
                                    completion(nil, error)
                                }
                        }
                    }
                }
            }
        }
    }
    
    func completeCharge(with token: STPToken, amount: Int, completion: @escaping (Result) -> Void) {
        
        guard let currentUser = Auth.auth().currentUser else { return }
        
        currentUser.getIDTokenForcingRefresh(true) { idToken, error in
            
            if let error = error {
                
                fatalError("Error getting user ID token: \(error)")
                
            } else {
                
                if let userIdToken = idToken {
                    
                    Alamofire.request(APIRouter.stripeChargeCreate(userIdToken: userIdToken, stripeToken: token.tokenId, amount: amount, currency: "gbp", description: "Order from RHS Uniform app"))
                        .validate(statusCode: 200..<300)
                        .responseString { response in
                            
                            switch response.result {
                            case .success:
                                completion(Result.success)
                            case .failure(let error):
                                completion(Result.failure(error))
                            }
                    }
                }
            }
        }
    }
}
