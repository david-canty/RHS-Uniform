//
//  KeychainSecuredItem.swift
//  RHS Uniform
//
//  Created by David Canty on 17/03/2018.
//  Copyright © 2018 ddijitall. All rights reserved.
//

import Foundation

struct KeychainSecuredItem {
    
    enum KeychainError: Error {
        case noSecuredItem
        case unexpectedSecuredItemData
        case unexpectedItemData
        case unhandledError(status: OSStatus)
    }
    
    let service: String
    private(set) var account: String
    let accessGroup: String?
    
    init(service: String, account: String, accessGroup: String? = nil) {
        self.service = service
        self.account = account
        self.accessGroup = accessGroup
    }
    
    func readSecuredItem() throws -> String  {

        var query = KeychainSecuredItem.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanTrue
        
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        
        guard status != errSecItemNotFound else { throw KeychainError.noSecuredItem }
        guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        
        guard let existingSecuredItem = queryResult as? [String : AnyObject],
            let securedItemData = existingSecuredItem[kSecValueData as String] as? Data,
            let securedItem = String(data: securedItemData, encoding: String.Encoding.utf8)
            else {
                throw KeychainError.unexpectedSecuredItemData
        }
        
        return securedItem
    }
    
    func saveSecuredItem(_ item: String) throws {

        let encodedItem = item.data(using: String.Encoding.utf8)!
        
        do {

            try _ = readSecuredItem()
            
            var attributesToUpdate = [String : AnyObject]()
            attributesToUpdate[kSecValueData as String] = encodedItem as AnyObject?
            
            let query = KeychainSecuredItem.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
            let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
            
            guard status == noErr else { throw KeychainError.unhandledError(status: status) }
            
        } catch KeychainError.noSecuredItem {

            var newItem = KeychainSecuredItem.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
            newItem[kSecValueData as String] = encodedItem as AnyObject?
            
            let status = SecItemAdd(newItem as CFDictionary, nil)
            
            guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        }
    }
    
    mutating func renameAccount(_ newAccountName: String) throws {
        
        var attributesToUpdate = [String : AnyObject]()
        attributesToUpdate[kSecAttrAccount as String] = newAccountName as AnyObject?
        
        let query = KeychainSecuredItem.keychainQuery(withService: service, account: self.account, accessGroup: accessGroup)
        let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
        
        guard status == noErr || status == errSecItemNotFound else { throw KeychainError.unhandledError(status: status) }
        
        self.account = newAccountName
    }
    
    func deleteItem() throws {

        let query = KeychainSecuredItem.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == noErr || status == errSecItemNotFound else { throw KeychainError.unhandledError(status: status) }
    }
    
    static func securedItems(forService service: String, accessGroup: String? = nil) throws -> [KeychainSecuredItem] {
        
        var query = KeychainSecuredItem.keychainQuery(withService: service, accessGroup: accessGroup)
        query[kSecMatchLimit as String] = kSecMatchLimitAll
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanFalse
        
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        
        guard status != errSecItemNotFound else { return [] }
        
        guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        
        guard let resultData = queryResult as? [[String : AnyObject]] else { throw KeychainError.unexpectedItemData }
        
        var securedItems = [KeychainSecuredItem]()
        for result in resultData {
            guard let account = result[kSecAttrAccount as String] as? String else { throw KeychainError.unexpectedItemData }
            
            let securedItem = KeychainSecuredItem(service: service, account: account, accessGroup: accessGroup)
            securedItems.append(securedItem)
        }
        
        return securedItems
    }
    
    private static func keychainQuery(withService service: String, account: String? = nil, accessGroup: String? = nil) -> [String : AnyObject] {
        
        var query = [String : AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = service as AnyObject?
        
        if let account = account {
            query[kSecAttrAccount as String] = account as AnyObject?
        }
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
        }
        
        return query
    }
}
