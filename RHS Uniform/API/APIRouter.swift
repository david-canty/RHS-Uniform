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
    
    case schools(userIdToken: String)
    case years(userIdToken: String)
    case categories(userIdToken: String)
    case sizes(userIdToken: String)
    case stocks(userIdToken: String)
    case items(userIdToken: String, categories: [Int], years: [Int], genders: [String])
    case item(userIdToken: String, id: Int)
    
    var method: HTTPMethod {
        
        switch self {
            
        case .schools:
            return .get
            
        case .years:
            return .get
            
        case .categories:
            return .get
            
        case .sizes:
            return .get
            
        case .stocks:
            return .get
            
        case .items:
            return .get
            
        case .item:
            return .get
        }
    }
    
    var path: String {
        
        switch self {
            
        case .schools:
            return "/schools"
            
        case .years:
            return "/years"
            
        case .categories:
            return "/categories"
            
        case .sizes:
            return "/sizes"
            
        case .stocks:
            return "/stocks"
            
        case .items:
            return "/items"

        case .item(let id):
            return "/items/\(id)"
        }
    }
    
    public func asURLRequest() throws -> URLRequest {
        
        let parameters: [String: Any] = {
            
            switch self {
                
            case let .items(_, categories, years, genders):
                
                return ["categories": categories, "years": years, "genders": genders]
                
            default:
                
                return [:]
                
            }
        }()
        
        let userIdToken: String = {
            
            switch self {
                
            case .schools(let idToken):
                
                return idToken
                
            case .categories(let idToken):
                
                return idToken
                
            case .years(let idToken):
                
                return idToken
                
            case .sizes(let idToken):
                
                return idToken
                
            case .stocks(let idToken):
                
                return idToken
                
            case .items(let idToken, _, _, _):
                
                return idToken
                
            case .item(let idToken, _):
                
                return idToken
            }
        }()
        
        let url = try AppConfig.sharedInstance.baseUrlPath().asURL()
        var request = URLRequest(url: url.appendingPathComponent(path))
        request.httpMethod = method.rawValue
        request.setValue(userIdToken, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = TimeInterval(10 * 1000)
        
        return try URLEncoding.default.encode(request, with: parameters)
    }
}
