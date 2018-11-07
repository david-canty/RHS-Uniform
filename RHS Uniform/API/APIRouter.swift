//
//  APIRouter.swift
//  RHS Uniform
//
//  Created by David Canty on 11/02/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import Foundation
import Alamofire

public enum APIRouter: URLRequestConvertible {
    
    case all(userIdToken: String)
    case schools(userIdToken: String)
    case years(userIdToken: String)
    case categories(userIdToken: String)
    case sizes(userIdToken: String)
    case items(userIdToken: String)
    case itemSizes(userIdToken: String)
    
    
    
    case stripeEphemeralKey(userIdToken: String, customerId: String, apiVersion: String)
    case stripeCustomerCreate(userIdToken: String, email: String)
    case stripeCustomerGet(userIdToken: String, customerId: String)
    case stripeCustomerSourceCreate(userIdToken: String, customerId: String, source: String)
    case stripeCustomerDefaultSource(userIdToken: String, customerId: String, defaultSource: String)
    
    case stripeChargeCreate(userIdToken: String, amount: Int, currency: String, description: String, customerId: String)
    
    var method: HTTPMethod {
        
        switch self {
            
        case .all:
            return .get
            
        case .schools:
            return .get
            
        case .years:
            return .get
            
        case .categories:
            return .get
            
        case .sizes:
            return .get
            
        case .items:
            return .get
        
        case .itemSizes:
            return .get
            
        case .stripeEphemeralKey:
            return .post
            
        case .stripeCustomerCreate:
            return .post
            
        case .stripeCustomerGet:
            return .get
            
        case .stripeCustomerSourceCreate:
            return .post
            
        case .stripeCustomerDefaultSource:
            return .patch
            
        case .stripeChargeCreate:
            return .post
        }
    }
    
    var path: String {
        
        switch self {
            
        case .all:
            return "/all"
            
        case .schools:
            return "/schools"
            
        case .years:
            return "/years"
            
        case .categories:
            return "/categories"
            
        case .sizes:
            return "/sizes"
            
        case .items:
            return "/items"
            
        case .itemSizes:
            return "/items/sizes"
            
        case .stripeEphemeralKey:
            return "/stripe/ephemeral-key"
            
        case .stripeCustomerCreate:
            return "/stripe/customer"
            
        case let .stripeCustomerGet(_, customerId):
            return "/stripe/customer/\(customerId)"
            
        case let .stripeCustomerSourceCreate(_, customerId, _):
            return "/stripe/customer/\(customerId)/source"
            
        case let .stripeCustomerDefaultSource(_, customerId, _):
            return "/stripe/customer/\(customerId)/default-source"
            
        case .stripeChargeCreate:
            return "/stripe/charge"
        }
    }
    
    public func asURLRequest() throws -> URLRequest {
        
        let parameters: [String: Any] = {
            
            switch self {
                
            case let .stripeEphemeralKey(_, customerId, apiVersion):
                
                return ["customerId": customerId,
                        "apiVersion": apiVersion]
                
            case let .stripeCustomerCreate(_, email):
                
                return ["email": email]
            
            case let .stripeCustomerSourceCreate(_, _, source):
                
                return ["source": source]
                
            case let .stripeCustomerDefaultSource(_, _, defaultSource):
                
                return ["source": defaultSource]
                
            case let .stripeChargeCreate(_, amount, currency, description, customerId):
                
                return ["amount": amount,
                        "currency": currency,
                        "description": description,
                        "customerId": customerId]
                
            default:
                
                return [:]
                
            }
        }()
        
        let userIdToken: String = {
            
            switch self {
                
            case .all (let idToken):
                return idToken
                
            case .schools (let idToken):
                return idToken
                
            case .categories (let idToken):
                return idToken
                
            case .years (let idToken):
                return idToken
                
            case .sizes (let idToken):
                return idToken
                
            case .items (let idToken):
                return idToken
                
            case .itemSizes (let idToken):
                return idToken
                
            case .stripeEphemeralKey (let idToken, _, _):
                return idToken
                
            case .stripeCustomerCreate (let idToken, _):
                return idToken
                
            case .stripeCustomerGet (let idToken, _):
                return idToken
                
            case .stripeCustomerSourceCreate (let idToken, _, _):
                return idToken
                
            case .stripeCustomerDefaultSource (let idToken, _, _):
                return idToken
                
            case .stripeChargeCreate (let idToken, _, _, _, _):
                return idToken
            }
        }()
        
        let url = try AppConfig.sharedInstance.baseUrlString().asURL()
        var request = URLRequest(url: url.appendingPathComponent(path))
        request.httpMethod = method.rawValue
        request.setValue(userIdToken, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = TimeInterval(10 * 1000)
        
        return try URLEncoding.default.encode(request, with: parameters)
    }
}
