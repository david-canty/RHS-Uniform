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
    
    case charge(userIdToken: String, stripeToken: String, amount: Int, currency: String, description: String)
    
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
            
        case .charge:
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
            
        case .charge:
            return "/charge"
        }
    }
    
    public func asURLRequest() throws -> URLRequest {
        
        let parameters: [String: Any] = {
            
            switch self {
                
            case let .charge(_, stripeToken, amount, currency, description):
                
                return ["token": stripeToken,
                        "amount": amount,
                        "currency": currency,
                        "description": description]
                
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
                
            case .charge (let idToken, _, _, _, _):
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
